from typing import Any

import httpx

from ai_experiments.home_assistant.config import Settings
from ai_experiments.home_assistant.models import EntityState, ServiceCall


class HomeAssistantClient:
    def __init__(self, settings: Settings) -> None:
        self._settings = settings
        self._client = httpx.Client(
            base_url=settings.ha_url,
            headers={
                "Authorization": f"Bearer {settings.ha_token}",
                "Content-Type": "application/json",
            },
            timeout=settings.request_timeout,
        )

    def close(self) -> None:
        self._client.close()

    def __enter__(self) -> "HomeAssistantClient":
        return self

    def __exit__(self, *_: object) -> None:
        self.close()

    def check_connection(self) -> dict[str, Any]:
        response = self._client.get("/api/")
        response.raise_for_status()
        return response.json()

    def get_config(self) -> dict[str, Any]:
        response = self._client.get("/api/config")
        response.raise_for_status()
        return response.json()

    def get_states(self) -> list[EntityState]:
        response = self._client.get("/api/states")
        response.raise_for_status()
        return [EntityState.from_api(item) for item in response.json()]

    def get_state(self, entity_id: str) -> EntityState:
        response = self._client.get(f"/api/states/{entity_id}")
        response.raise_for_status()
        return EntityState.from_api(response.json())

    def call_service(self, call: ServiceCall) -> list[dict[str, Any]]:
        payload: dict[str, Any] = {}
        if call.entity_id:
            payload["entity_id"] = call.entity_id
        if call.data:
            payload.update(call.data)

        response = self._client.post(
            f"/api/services/{call.domain}/{call.service}",
            json=payload,
        )
        response.raise_for_status()
        return response.json()

    def search_entities(
        self,
        *,
        query: str = "",
        domain: str | None = None,
        limit: int = 25,
    ) -> list[EntityState]:
        query_lower = query.lower()
        results: list[EntityState] = []

        for entity in self.get_states():
            if domain and entity.domain != domain:
                continue

            haystack = " ".join(
                [
                    entity.entity_id,
                    entity.friendly_name,
                    entity.state,
                ]
            ).lower()

            if query_lower and query_lower not in haystack:
                continue

            results.append(entity)
            if len(results) >= limit:
                break

        return results
