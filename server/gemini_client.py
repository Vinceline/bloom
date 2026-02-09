"""
Bloom — Gemini Client
======================
Thin wrapper around google.genai. All agents call through here.
Single place to swap models, set defaults, handle errors.
"""

import os
import sys
from dotenv import load_dotenv
from google import genai
from google.genai import types

load_dotenv()

MODEL = "gemini-3-pro-preview"


def get_client() -> genai.Client:
    """Initialize and return a Gemini client. Exits if no API key."""
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("❌ GEMINI_API_KEY not set. Add it to .env")
        sys.exit(1)
    return genai.Client(api_key=api_key)


# Module-level client — created once on import
client = get_client()


from google.genai import types

def call(contents: list, model: str = MODEL) -> str:
    try:
        response = client.models.generate_content(
            model=model,
            contents=contents,
            config=types.GenerateContentConfig(
                safety_settings=[
                    # Categories MUST have the HARM_CATEGORY_ prefix
                    types.SafetySetting(
                        category="HARM_CATEGORY_HATE_SPEECH", 
                        threshold="BLOCK_NONE"
                    ),
                    types.SafetySetting(
                        category="HARM_CATEGORY_HARASSMENT", 
                        threshold="BLOCK_NONE"
                    ),
                    types.SafetySetting(
                        category="HARM_CATEGORY_DANGEROUS_CONTENT", 
                        threshold="BLOCK_NONE"
                    ),
                    types.SafetySetting(
                        category="HARM_CATEGORY_SEXUALLY_EXPLICIT", 
                        threshold="BLOCK_ONLY_HIGH"
                    ),
                ]
            )
        )
        return response.text
    except Exception as e:
        raise RuntimeError(f"Gemini API error: {e}")

def call_with_confidence(contents: list, model: str = MODEL) -> tuple[str, str]:
    response = client.models.generate_content(
        model=model,
        contents=contents
    )
    text = response.text

    confidence_prompt = (
        "Briefly rate your confidence in this response from 0–1 "
        "and say what information would change your decision."
    )

    confidence_resp = client.models.generate_content(
        model=model,
        contents=[text, confidence_prompt]
    )

    return text, confidence_resp.text
