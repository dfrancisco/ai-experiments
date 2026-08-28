import os
import time

import httpx
from dotenv import load_dotenv

load_dotenv()


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
    "answer": data["output"][0]["content"][0]["text"],
    "elapsed_seconds": elapsed,
}

    result = call_model(
        "openrouter/free",
        "Explain in two sentences why AI agents are interesting.",
    )

    print(result)

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

for model in models:
    print(f"\n{'=' * 60}")
    print(model)

    try:
        result = call_model(model, prompt)
        
        print(f"Actual model: {result['model']}")
        print(f"Latency: {result['elapsed_seconds']:.2f}s")
        print(f"Answer:\n{result['answer']}")
    except Exception as e:
        print(f"ERROR: {type(e).__name__}: {e}")