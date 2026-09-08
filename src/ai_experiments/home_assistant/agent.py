import json
from typing import Any

import httpx

from ai_experiments.home_assistant.client import HomeAssistantClient
from ai_experiments.home_assistant.config import Settings
from ai_experiments.home_assistant.context import summarize_entities
from ai_experiments.home_assistant.tools import TOOL_DEFINITIONS, ToolExecutor

SYSTEM_PROMPT = """You are a smart home assistant that controls devices through Home Assistant.

Rules:
- Use the provided tools to inspect state and control devices.
- Prefer exact entity ids from search results before calling services.
- Confirm actions clearly and mention what changed.
- Ask for clarification only when the request is ambiguous.
- Do not invent entities or services that were not discovered through tools.
"""


class HomeAssistantAgent:
    def __init__(self, settings: Settings, client: HomeAssistantClient) -> None:
        self._settings = settings
        self._client = client
        self._tools = ToolExecutor(client)
        self._http = httpx.Client(timeout=settings.request_timeout)

    def close(self) -> None:
        self._http.close()

    def __enter__(self) -> "HomeAssistantAgent":
        return self

    def __exit__(self, *_: object) -> None:
        self.close()

    @classmethod
    def from_env(cls) -> "HomeAssistantAgent":
        settings = Settings.from_env()
        client = HomeAssistantClient(settings)
        return cls(settings, client)

    def run(self, user_message: str, *, max_tool_rounds: int = 5) -> str:
        entity_summary = summarize_entities(self._client.get_states())
        messages: list[dict[str, Any]] = [
            {"role": "system", "content": SYSTEM_PROMPT},
            {
                "role": "user",
                "content": (
                    f"Current controllable devices:\n{entity_summary}\n\n"
                    f"User request: {user_message}"
                ),
            },
        ]

        for _ in range(max_tool_rounds):
            response = self._chat(messages)
            message = response["choices"][0]["message"]
            tool_calls = message.get("tool_calls") or []

            if not tool_calls:
                content = message.get("content")
                if not content:
                    raise ValueError(f"Model returned no content: {response}")
                return content.strip()

            messages.append(message)
            for tool_call in tool_calls:
                function = tool_call["function"]
                arguments = json.loads(function.get("arguments") or "{}")
                tool_result = self._tools.run(function["name"], arguments)
                messages.append(
                    {
                        "role": "tool",
                        "tool_call_id": tool_call["id"],
                        "content": tool_result,
                    }
                )

        raise RuntimeError("Exceeded maximum tool rounds without a final answer")

    def _chat(self, messages: list[dict[str, Any]]) -> dict[str, Any]:
        response = self._http.post(
            "https://openrouter.ai/api/v1/chat/completions",
            headers={
                "Authorization": f"Bearer {self._settings.openrouter_api_key}",
                "Content-Type": "application/json",
            },
            json={
                "model": self._settings.model,
                "messages": messages,
                "tools": TOOL_DEFINITIONS,
            },
        )
        response.raise_for_status()
        return response.json()
