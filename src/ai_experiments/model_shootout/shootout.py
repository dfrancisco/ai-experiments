import json
import os
import re
import time

import httpx
from dotenv import load_dotenv

load_dotenv()

DEFAULT_JUDGE_MODEL = os.environ.get("JUDGE_MODEL", "openrouter/free")


def _extract_answer(data: dict) -> str:
    output = data.get("output", [])
    message_parts: list[str] = []
    fallback_parts: list[str] = []

    for item in output:
        for content in item.get("content", []):
            text = content.get("text", "")
            if not text:
                continue

            if item.get("type") == "message" and content.get("type") == "output_text":
                message_parts.append(text)
            elif content.get("type") != "reasoning_text":
                fallback_parts.append(text)

    if message_parts:
        return "\n".join(message_parts)
    if fallback_parts:
        return "\n".join(fallback_parts)

    raise ValueError(f"No text in model response: {data}")


def call_model(model: str, prompt: str) -> dict:
    start = time.perf_counter()

    response = httpx.post(
        "https://openrouter.ai/api/v1/responses",
        headers={
            "Authorization": f"Bearer {os.environ['OPENROUTER_API_KEY']}",
            "Content-Type": "application/json",
        },
        json={
            "model": model,
            "input": prompt,
        },
        timeout=60.0,
    )

    response.raise_for_status()
    data = response.json()

    elapsed = time.perf_counter() - start

    return {
        "model": data["model"],
        "answer": _extract_answer(data),
        "elapsed_seconds": elapsed,
    }


def _parse_judge_verdict(raw: str) -> dict:
    text = raw.strip()
    if not text:
        raise ValueError("Judge returned empty response")

    fence_match = re.search(r"```(?:json)?\s*(.*?)\s*```", text, re.DOTALL)
    if fence_match:
        text = fence_match.group(1).strip()

    try:
        return json.loads(text)
    except json.JSONDecodeError:
        brace_match = re.search(r"\{.*\}", text, re.DOTALL)
        if brace_match:
            return json.loads(brace_match.group(0))
        raise


def judge_responses(
    prompt: str,
    answers: dict[str, str],
    judge_model: str = DEFAULT_JUDGE_MODEL,
) -> dict:
    """Use an LLM to pick the best response among competing models."""
    if len(answers) < 2:
        raise ValueError("Need at least two responses to judge")

    labels = [chr(ord("A") + i) for i in range(len(answers))]
    label_to_model = dict(zip(labels, answers.keys(), strict=True))

    responses_block = "\n\n".join(
        f"### Response {label}\n{answer}"
        for label, answer in zip(labels, answers.values(), strict=True)
    )

    judge_prompt = f"""You are an impartial judge evaluating LLM responses to the same prompt.

Original prompt:
{prompt.strip()}

{responses_block}

Evaluate each response on relevance, quality, depth, and how well it follows the prompt.
Pick the single best response.

Respond with ONLY valid JSON in this format:
{{
  "winner": "<label>",
  "reasoning": "<brief explanation>",
  "rankings": ["<best label>", "<second label>", "..."]
}}"""

    result = call_model(judge_model, judge_prompt)
    verdict = _parse_judge_verdict(result["answer"])

    winner_label = verdict["winner"].strip().upper()
    if winner_label not in label_to_model:
        raise ValueError(f"Judge returned unknown label: {winner_label!r}")

    return {
        "judge_model": result["model"],
        "winner": label_to_model[winner_label],
        "winner_label": winner_label,
        "reasoning": verdict["reasoning"],
        "rankings": [
            {
                "label": label.strip().upper(),
                "model": label_to_model[label.strip().upper()],
            }
            for label in verdict["rankings"]
        ],
        "elapsed_seconds": result["elapsed_seconds"],
    }


if __name__ == "__main__":
    models = [
        "nvidia/nemotron-3-super-120b-a12b:free",
        "minimax/minimax-m3:free",
        "minimax/minimax-m2.7:free",
    ]

    prompt = """
    I have a year off between jobs and want to use it to become significantly
    better at building with AI. Give me three unconventional ways to use that
    time. Optimize for learning and interestingness, not making money.
    """
    answers = {}

    for model in models:
        print(f"\n{'=' * 60}")
        print(model)

        try:
            result = call_model(model, prompt)

            print(f"Actual model: {result['model']}")
            print(f"Latency: {result['elapsed_seconds']:.2f}s")
            print(f"Answer:\n{result['answer']}")

            answers[model] = result["answer"]
        except Exception as e:
            print(f"ERROR: {type(e).__name__}: {e}")

    if len(answers) >= 2:
        print(f"\n{'=' * 60}")
        print("LLM JUDGE")
        print(f"Judge model: {DEFAULT_JUDGE_MODEL}")

        try:
            verdict = judge_responses(prompt, answers)

            print(f"Actual judge: {verdict['judge_model']}")
            print(f"Latency: {verdict['elapsed_seconds']:.2f}s")
            print(f"\nWinner: {verdict['winner']} (Response {verdict['winner_label']})")
            print(f"Reasoning: {verdict['reasoning']}")
            print("\nRankings:")
            for rank, entry in enumerate(verdict["rankings"], start=1):
                print(f"  {rank}. Response {entry['label']} — {entry['model']}")
        except Exception as e:
            print(f"ERROR: {type(e).__name__}: {e}")
            if "JSON" in type(e).__name__:
                print("(The judge model did not return parseable JSON.)")
    else:
        print("\nSkipping judge: need at least two successful responses.")
