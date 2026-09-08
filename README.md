# ai-experiments

Experiments in building with AI.

## Projects

| Module | Description |
|--------|-------------|
| [`home_assistant`](src/ai_experiments/home_assistant/) | Smart AI layer for controlling Home Assistant with natural language |
| [`model_shootout`](src/ai_experiments/model_shootout/) | Compare LLM responses with an automated judge |

## Quick start

```bash
uv sync
cp .env.example .env   # add your API keys
uv run ha-ai ping      # verify Home Assistant connection
```
