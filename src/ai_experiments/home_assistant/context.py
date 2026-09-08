from ai_experiments.home_assistant.models import EntityState

CONTROLLABLE_DOMAINS = {
    "light",
    "switch",
    "fan",
    "cover",
    "climate",
    "media_player",
    "lock",
    "scene",
    "script",
    "input_boolean",
    "vacuum",
}


def format_entity(entity: EntityState) -> str:
    details = [f"{entity.friendly_name} ({entity.entity_id}): {entity.state}"]

    for key in ("brightness", "color_temp", "temperature", "hvac_mode", "volume_level"):
        if key in entity.attributes:
            details.append(f"{key}={entity.attributes[key]}")

    return " | ".join(details)


def summarize_entities(entities: list[EntityState], *, limit: int = 40) -> str:
    controllable = [entity for entity in entities if entity.domain in CONTROLLABLE_DOMAINS]
    selected = controllable[:limit]

    if not selected:
        return "No controllable entities found."

    lines = [format_entity(entity) for entity in selected]
    if len(controllable) > limit:
        lines.append(f"... and {len(controllable) - limit} more controllable entities")

    return "\n".join(lines)
