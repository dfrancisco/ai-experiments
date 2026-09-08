import os
from dataclasses import dataclass

from dotenv import load_dotenv

load_dotenv()


@dataclass(frozen=True)
class Settings:
    ha_url: str
    ha_token: str
    openrouter_api_key: str
    model: str = "openrouter/free"
    request_timeout: float = 30.0

    @classmethod
    def from_env(cls) -> "Settings":
        missing = [
            name
            for name, value in [
                ("HA_URL", os.environ.get("HA_URL")),
                ("HA_TOKEN", os.environ.get("HA_TOKEN")),
                ("OPENROUTER_API_KEY", os.environ.get("OPENROUTER_API_KEY")),
            ]
            if not value
        ]
        if missing:
            raise ValueError(
                f"Missing required environment variables: {', '.join(missing)}"
            )

        return cls(
            ha_url=os.environ["HA_URL"].rstrip("/"),
            ha_token=os.environ["HA_TOKEN"],
            openrouter_api_key=os.environ["OPENROUTER_API_KEY"],
            model=os.environ.get("HA_AI_MODEL", "openrouter/free"),
            request_timeout=float(os.environ.get("HA_AI_TIMEOUT", "30")),
        )
