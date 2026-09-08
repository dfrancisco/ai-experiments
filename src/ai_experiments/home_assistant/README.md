# Home Assistant AI Layer

Natural language control for Home Assistant. This module connects to your HA instance, discovers entities, and uses an LLM with tool calling to interpret commands and execute them.

## Setup

1. Create a long-lived access token in Home Assistant:
   Profile → Security → Long-Lived Access Tokens

2. Copy `.env.example` to `.env` and fill in your values:

```bash
cp .env.example .env
```

3. Install dependencies:

```bash
uv sync
```

## Usage

Verify connectivity:

```bash
uv run ha-ai ping
```

List entities:

```bash
uv run ha-ai entities
uv run ha-ai entities --query living --domain light
```

Send a natural language command:

```bash
uv run ha-ai ask "turn off the living room lights"
uv run ha-ai ask "set the thermostat to 72"
```

## Architecture

```
User prompt
    ↓
HomeAssistantAgent
    ├── context.py   → summarizes controllable entities for the LLM
    ├── tools.py     → search_entities, get_entity_state, call_service
    └── agent.py     → OpenRouter chat + tool loop
            ↓
    HomeAssistantClient (REST API)
            ↓
    Home Assistant
```

## Next steps

- WebSocket connection for real-time state updates
- Conversation memory / multi-turn sessions
- Safety rules (confirm destructive actions, time-based limits)
- Voice input via Whisper or HA Assist
- MCP server exposing HA tools to Cursor agents
