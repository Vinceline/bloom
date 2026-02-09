"""
Bloom — Partner Agent
======================
Specialist agent for the Partner pillar. The differentiator —
every prompt pulls from the full shared context so the partner
gets specific, actionable suggestions based on what's actually
happening right now.
"""

import json
import gemini_client
from context import BloomContext
from prompts import partner as partner_prompts


ACTION_MAP = {
    "help_suggestion":          partner_prompts.help_suggestion,
    "emotional_support":        partner_prompts.emotional_support,
    "feeding_help":             partner_prompts.feeding_help,
    "general_partner_support":  partner_prompts.general_partner_support,
}


class PartnerAgent:

    def run(self, context: BloomContext) -> None:
        action = context.routed_action or "general_partner_support"

        prompt_fn = ACTION_MAP.get(action, partner_prompts.general_partner_support)
        prompt = prompt_fn(
            user_message=context.user_message,
            context=context.user_context
        )

        # Partner pillar is text-only — no image needed
        try:
            raw, confidence = gemini_client.call_with_confidence([prompt])
            context.confidence_log.append({
            "agent": "mind",
            "action": action,
            "confidence": confidence
            })
        except RuntimeError as e:
            context.error = str(e)
            return

        context.response = self._parse(raw)
        context.response["pillar"] = "partner"
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
                "title": "How to help",
                "content": raw.strip(),
                "suggestion": None,
                "partnerActions": []
            }