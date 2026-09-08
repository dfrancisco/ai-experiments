from dataclasses import dataclass
from typing import Any


@dataclass(frozen=True)
class EntityState:
    entity_id: str
    state: str
    friendly_name: str
    domain: str
    attributes: dict[str, Any]

    @classmethod
    def from_api(cls, data: dict[str, Any]) -> "EntityState":
        entity_id = data["entity_id"]
        attributes = data.get("attributes", {})
        return cls(
            entity_id=entity_id,
            state=data.get("state", "unknown"),
            friendly_name=attributes.get("friendly_name", entity_id),
            domain=entity_id.split(".", 1)[0],
            attributes=attributes,
        )


@dataclass(frozen=True)
class ServiceCall:
    domain: str
    service: str
    entity_id: str | None = None
    data: dict[str, Any] | None = None
