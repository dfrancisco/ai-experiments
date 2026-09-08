import json
from typing import Any

from ai_experiments.home_assistant.client import HomeAssistantClient
from ai_experiments.home_assistant.models import ServiceCall

TOOL_DEFINITIONS: list[dict[str, Any]] = [
    {
        "type": "function",
        "function": {
            "name": "search_entities",
            "description": "Find Home Assistant entities by name, id, or domain.",
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "Text to match against entity id or friendly name.",
                    },
                    "domain": {
                        "type": "string",
                        "description": "Optional domain filter, e.g. light or switch.",
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Maximum number of entities to return.",
                        "default": 10,
                    },
                },
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "get_entity_state",
            "description": "Get the current state of a specific entity.",
            "parameters": {
                "type": "object",
                "properties": {
                    "entity_id": {
                        "type": "string",
                        "description": "The entity id, e.g. light.living_room.",
                    },
                },
                "required": ["entity_id"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "call_service",
            "description": "Call a Home Assistant service to control a device.",
            "parameters": {
                "type": "object",
                "properties": {
                    "domain": {
                        "type": "string",
                        "description": "Service domain, e.g. light.",
                    },
                    "service": {
                        "type": "string",
                        "description": "Service name, e.g. turn_on or turn_off.",
                    },
                    "entity_id": {
                        "type": "string",
                        "description": "Target entity id.",
                    },
                    "data": {
                        "type": "object",
                        "description": "Optional extra service data such as brightness or temperature.",
                    },
                },
                "required": ["domain", "service"],
            },
        },
    },
]


class ToolExecutor:
    def __init__(self, client: HomeAssistantClient) -> None:
        self._client = client

    def run(self, name: str, arguments: dict[str, Any]) -> str:
        if name == "search_entities":
            entities = self._client.search_entities(
                query=arguments.get("query", ""),
                domain=arguments.get("domain"),
                limit=int(arguments.get("limit", 10)),
            )
            if not entities:
                return "No matching entities found."
            return "\n".join(
                f"{entity.friendly_name} ({entity.entity_id}): {entity.state}"
                for entity in entities
            )

        if name == "get_entity_state":
            entity = self._client.get_state(arguments["entity_id"])
            return json.dumps(
                {
                    "entity_id": entity.entity_id,
                    "state": entity.state,
                    "friendly_name": entity.friendly_name,
                    "attributes": entity.attributes,
                }
            )

        if name == "call_service":
            call = ServiceCall(
                domain=arguments["domain"],
                service=arguments["service"],
                entity_id=arguments.get("entity_id"),
                data=arguments.get("data"),
            )
            result = self._client.call_service(call)
            return json.dumps({"status": "ok", "result": result})

        raise ValueError(f"Unknown tool: {name}")
