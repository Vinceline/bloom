"""
Bloom — Pipeline Orchestrator
==============================
The heart of the agentic system. Owns the execution flow:

  1. Build BloomContext from the incoming request
  2. Run RouterAgent → writes routing decision to context
  3. Look up the task in the registry
  4. Dynamically import and run the specialist agent
  5. Yield SSE events at each stage for real-time iOS feedback

Agents don't know about each other. They don't call each other.
The pipeline is the only thing that orchestrates them.
"""

import json
import base64
import importlib
from io import BytesIO
from typing import Generator
from PIL import Image

from context import BloomContext
from tasks import get_task
from agents.router_agent import RouterAgent


# Maps pillar names to their agent module + class for dynamic import.
# Adding a new pillar = add one line here + new agent file. Nothing else changes.
SPECIALIST_AGENTS = {
    "mind":    ("agents.mind_agent",    "MindAgent"),
    "body":    ("agents.body_agent",    "BodyAgent"),
    "baby":    ("agents.baby_agent",    "BabyAgent"),
    "partner": ("agents.partner_agent", "PartnerAgent"),
}


def _sse_event(event_type: str, data: dict) -> str:
    """Format a single SSE event."""
    return f"event: {event_type}\ndata: {json.dumps(data)}\n\n"


def run_pipeline(request_body: dict) -> Generator[str, None, None]:
    """
    Main entry point. Called by server.py with the parsed JSON body.
    Yields SSE event strings the server streams back to the iOS app.

    SSE events fired in order:
      "status"  → "Thinking..." (immediate, before any Gemini call)
      "routed"  → { pillar, action, reasoning } (after router completes)
      "result"  → the full BloomResponse JSON (after specialist completes)
      "error"   → { error } if anything fails
    """

    # ── Step 0: Build context ──
    context = BloomContext(
        user_message=request_body.get("message", ""),
        pillar_hint=request_body.get("pillar", None),
        user_context=request_body.get("context", {}),
    )

    # Decode image if present
    image_data = request_body.get("image_data", None)
    if image_data:
        try:
            img_bytes = base64.b64decode(image_data)
            context.image = Image.open(BytesIO(img_bytes)).convert("RGB")
        except Exception as e:
            yield _sse_event("error", {"error": f"Image decode failed: {e}"})
            return

    # ── Step 1: Status event ──
    yield _sse_event("status", {"message": "Thinking..."})

    # ── Step 2: Run Router ──
    router = RouterAgent()
    router.run(context)

    context.event_history.append({
    "step": "router",
    "pillar": context.routed_pillar,
    "action": context.routed_action,
    "reasoning": context.router_reasoning
})

    if context.error:
        yield _sse_event("error", {"error": context.error})
        return

    # ── Step 3: Fire "routed" event ──
    yield _sse_event("routed", {
        "pillar":    context.routed_pillar,
        "action":    context.routed_action,
        "reasoning": context.router_reasoning,
    })

    # ── Step 4: Look up task + validate ──
    task = get_task(context.routed_pillar, context.routed_action)
    if task is None:
        # Router picked something invalid — fall back to general support for that pillar
        context.routed_action = f"general_{'support' if context.routed_pillar != 'baby' else 'baby_support'}"
        task = get_task(context.routed_pillar, context.routed_action)

    if task and task.requires_image and not context.has_image:
        # Task needs an image but none was uploaded — fall back
        fallback_actions = {
            "body": "recovery_guidance",
            "baby": "general_baby_support",
        }
        context.routed_action = fallback_actions.get(context.routed_pillar, "general_support")

    # ── Step 5: Run Specialist ──
    agent_module_path, agent_class_name = SPECIALIST_AGENTS.get(
        context.routed_pillar,
        ("agents.mind_agent", "MindAgent")   # ultimate fallback
    )

    context.event_history.append({
    "step": "specialist",
    "pillar": context.routed_pillar,
    "response_summary": (
        context.response.get("title")
        if isinstance(context.response, dict)
        else None
    )
})

    try:
        module = importlib.import_module(agent_module_path)
        agent_class = getattr(module, agent_class_name)
        agent = agent_class()
        agent.run(context)
    except Exception as e:
        yield _sse_event("error", {"error": f"Specialist failed: {e}"})
        return

    if context.error:
        yield _sse_event("error", {"error": context.error})
        return

    # ── Step 6: Fire "result" event ──
    yield _sse_event("result", context.response or {"error": "No response generated"})