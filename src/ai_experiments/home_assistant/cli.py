import argparse
import sys

import httpx

from ai_experiments.home_assistant.agent import HomeAssistantAgent
from ai_experiments.home_assistant.client import HomeAssistantClient
from ai_experiments.home_assistant.config import Settings


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="ha-ai",
        description="Natural language control layer for Home Assistant.",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    ping = subparsers.add_parser("ping", help="Verify Home Assistant connectivity")
    ping.set_defaults(func=cmd_ping)

    ask = subparsers.add_parser("ask", help="Send a natural language command")
    ask.add_argument("prompt", help="What you want to do")
    ask.set_defaults(func=cmd_ask)

    entities = subparsers.add_parser("entities", help="List controllable entities")
    entities.add_argument("--query", default="", help="Optional search text")
    entities.add_argument("--domain", default=None, help="Optional domain filter")
    entities.set_defaults(func=cmd_entities)

    return parser


def cmd_ping(_: argparse.Namespace) -> int:
    settings = Settings.from_env()
    with HomeAssistantClient(settings) as client:
        info = client.check_connection()
        config = client.get_config()
        print(f"Connected to Home Assistant {info.get('version', 'unknown')}")
        print(f"Location: {config.get('location_name', 'unknown')}")
    return 0


def cmd_entities(args: argparse.Namespace) -> int:
    settings = Settings.from_env()
    with HomeAssistantClient(settings) as client:
        matches = client.search_entities(
            query=args.query,
            domain=args.domain,
            limit=50,
        )
        for entity in matches:
            print(f"{entity.entity_id:40} {entity.state:12} {entity.friendly_name}")
    return 0


def cmd_ask(args: argparse.Namespace) -> int:
    with HomeAssistantAgent.from_env() as agent:
        response = agent.run(args.prompt)
        print(response)
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        return args.func(args)
    except ValueError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1
    except httpx.HTTPStatusError as exc:
        print(f"HTTP error: {exc.response.status_code} {exc.response.text}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
