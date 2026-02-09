"""
Bloom — Body Agent
===================
Specialist agent for the Body pillar. Handles recovery guidance,
healing photo analysis, exercise recommendations, and symptom checks.

Photo analysis includes the image in the Gemini call — this is one
of the two key multimodal features in Bloom.
"""

import json
import gemini_client
from context import BloomContext
from prompts import body as body_prompts


ACTION_MAP = {
    "recovery_guidance":        body_prompts.recovery_guidance,
    "photo_analysis":           body_prompts.photo_analysis,
    "exercise_recommendation":  body_prompts.exercise_recommendation,
    "symptom_check":            body_prompts.symptom_check,
}


class BodyAgent:

    def run(self, context: BloomContext) -> None:
        action = context.routed_action or "recovery_guidance"

        prompt_fn = ACTION_MAP.get(action, body_prompts.recovery_guidance)
        prompt = prompt_fn(
            user_message=context.user_message,
            context=context.user_context
        )

        # Body agent includes image if present (photo_analysis needs it)
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
        context.response["pillar"] = "body"
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
                "title": "Recovery Update",
                "content": raw.strip(),
                "suggestion": None,
                "exerciseSteps": None
            }