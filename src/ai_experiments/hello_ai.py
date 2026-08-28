import os

import httpx
from dotenv import load_dotenv

load_dotenv()

response = httpx.post(
    "https://openrouter.ai/api/v1/responses",
    headers={
        "Authorization": f"Bearer {os.environ['OPENROUTER_API_KEY']}",
        "Content-Type": "application/json",
    },
    json={
        "model": "openrouter/free",
        "input": "Say hello and tell me one interesting thing about AI.",
    },
)

print(response.status_code)
print(response.text)





