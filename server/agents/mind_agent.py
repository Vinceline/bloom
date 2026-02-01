"""
Bloom — Mind Agent
===================
Specialist agent for the Mind pillar. Handles mood check-ins,
mood analysis, breathing exercises, and general emotional support.
"""

import json
import gemini_client
from context import BloomContext
from prompts import mind as mind_prompts


# Maps action names to prompt builder functions
ACTION_MAP = {
    "mood_checkin":       mind_prompts.mood_checkin,
    "mood_analysis":      mind_prompts.mood_analysis,
    "breathing_exercise": mind_prompts.breathing_exercise,
    "general_support":    mind_prompts.general_support,
}


class MindAgent:

    def run(self, context: BloomContext) -> None:
        """
        Execute the Mind specialist. Reads context.routed_action
        to pick the right prompt, calls Gemini, writes the parsed
        response to context.response.
        """
        action = context.routed_action or "general_support"

        # Look up the prompt builder
        prompt_fn = ACTION_MAP.get(action, mind_prompts.general_support)
        prompt = prompt_fn(
            user_message=context.user_message,
            context=context.user_context
        )

        # Call Gemini
        try:
            raw = gemini_client.call([prompt])
        except RuntimeError as e:
            context.error = str(e)
            return

        # Parse and write to context
        context.response = self._parse(raw)
        context.response["pillar"] = "mind"
        context.steps_completed.append("specialist")

    def _parse(self, raw: str) -> dict:
        cleaned = raw.strip()
        if cleaned.startswith("```json"):
            cleaned = cleaned[7:]
        if cleaned.startswith("```"):
            cleaned = cleaned[3:]
        if cleaned.endswith("```"):
            cleaned = cleaned[:-3]

        try:
            return json.loads(cleaned.strip())
        except json.JSONDecodeError:
            return {
                "title": "A moment for you",
                "content": raw.strip(),
                "suggestion": None,
                "moodInsight": None
            }