"""
Bloom — Baby Agent
===================
Specialist agent for the Baby pillar. Handles cue reading from
photos, feeding guidance, sleep guidance, and general baby support.

Cue reading includes the image in the Gemini call — the second
key multimodal feature in Bloom (baby photo → state detection).
"""

import json
import gemini_client
from context import BloomContext
from prompts import baby as baby_prompts


ACTION_MAP = {
    "cue_reading":            baby_prompts.cue_reading,
    "feeding_guidance":       baby_prompts.feeding_guidance,
    "sleep_guidance":         baby_prompts.sleep_guidance,
    "general_baby_support":   baby_prompts.general_baby_support,
}


class BabyAgent:

    def run(self, context: BloomContext) -> None:
        action = context.routed_action or "general_baby_support"

        prompt_fn = ACTION_MAP.get(action, baby_prompts.general_baby_support)
        prompt = prompt_fn(
            user_message=context.user_message,
            context=context.user_context
        )

        # Baby agent includes image if present (cue_reading needs it)
        contents = [prompt]
        if context.has_image:
            contents = [context.image, prompt]

        try:
            raw, confidence = gemini_client.call_with_confidence(contents)
            context.confidence_log.append({
            "agent": "mind",
            "action": action,
            "confidence": confidence
            })
        except RuntimeError as e:
            context.error = str(e)
            return

        context.response = self._parse(raw)
        context.response["pillar"] = "baby"
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
                "title": "Baby Update",
                "content": raw.strip(),
                "suggestion": None,
                "babyReadout": None
            }