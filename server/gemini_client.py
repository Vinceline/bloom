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

load_dotenv()

MODEL = "gemini-2.0-flash"


def get_client() -> genai.Client:
    """Initialize and return a Gemini client. Exits if no API key."""
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("❌ GEMINI_API_KEY not set. Add it to .env")
        sys.exit(1)
    return genai.Client(api_key=api_key)


# Module-level client — created once on import
client = get_client()


def call(contents: list, model: str = MODEL) -> str:
    """
    Make a Gemini API call. Returns the raw text response.

    Args:
        contents: List of content parts (strings, PIL Images, etc.)
        model: Model to use. Defaults to the module-level MODEL.

    Returns:
        The text of Gemini's response.

    Raises:
        RuntimeError if the API call fails.
    """
    try:
        response = client.models.generate_content(
            model=model,
            contents=contents
        )
        return response.text
    except Exception as e:
        raise RuntimeError(f"Gemini API error: {e}")