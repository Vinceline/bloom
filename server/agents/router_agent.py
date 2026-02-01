"""
Bloom — Router Agent
=====================
Step 1 of the agentic pipeline. Reads the user's input and context,
decides which task to route to, writes the decision to context.

The pipeline reads context.routed_pillar + context.routed_action
after this agent runs to know what specialist to execute next.
"""

import json
import gemini_client
from context import BloomContext
from prompts.router import build_router_prompt
from tasks import all_task_names


class RouterAgent:

    def run(self, context: BloomContext) -> None:
        """
        Execute the routing step. Writes to:
          context.routed_pillar
          context.routed_action
          context.router_reasoning
        Sets context.error if something goes wrong.
        """
        # Build the prompt with the live task registry
        prompt = build_router_prompt(
            user_message=context.user_message,
            pillar_hint=context.pillar_hint or "none",
            context_json=json.dumps(context.user_context, indent=2),
            available_tasks=all_task_names()
        )

        # Call Gemini — include image if present so router can see what's being analyzed
        contents = [prompt]
        if context.has_image:
            contents = [context.image, prompt]

        try:
            raw = gemini_client.call(contents)
        except RuntimeError as e:
            context.error = str(e)
            return

        # Parse the JSON response
        route = self._parse(raw)

        # Extract pillar and action from the task name (e.g. "mind.mood_checkin")
        task_name = route.get("task", "mind.general_support")
        parts = task_name.split(".", 1)

        context.routed_pillar   = parts[0] if len(parts) == 2 else "mind"
        context.routed_action   = parts[1] if len(parts) == 2 else "general_support"
        context.router_reasoning = route.get("reasoning", "")
        context.steps_completed.append("router")

    def _parse(self, raw: str) -> dict:
        """Extract JSON from the router's response, handling markdown fences."""
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
            # Safe fallback
            return {
                "task": "mind.general_support",
                "reasoning": "Could not parse router output, defaulting to general support."
            }