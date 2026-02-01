"""
Bloom — Pipeline Context
=========================
The single shared state object that travels through the entire
agentic pipeline. Every agent reads from it, writes to it.
No global state, no random dicts — everything lives here.
"""

from dataclasses import dataclass, field
from typing import Optional
from PIL import Image


@dataclass
class BloomContext:
    # ── Inputs (set by server from the HTTP request) ──
    user_message: str = ""
    pillar_hint: Optional[str] = None       # tab the user is on, or None
    user_context: dict = field(default_factory=dict)  # full UserProfile from iOS
    image: Optional[Image.Image] = None     # decoded PIL image if uploaded

    # ── Router output (written by RouterAgent) ──
    routed_pillar: Optional[str] = None     # "mind" | "body" | "baby" | "partner"
    routed_action: Optional[str] = None     # e.g. "mood_checkin", "cue_reading"
    router_reasoning: Optional[str] = None  # why the router picked this route

    # ── Specialist output (written by the specialist agent) ──
    response: Optional[dict] = None         # the final BloomResponse JSON

    # ── Pipeline metadata ──
    error: Optional[str] = None             # set if anything fails
    steps_completed: list = field(default_factory=list)  # ["router", "specialist"]

    # ── Convenience accessors for agents ──
    @property
    def user_role(self) -> str:
        return self.user_context.get("user_role", "mom")

    @property
    def recovery_stage(self) -> str:
        return self.user_context.get("recovery_stage", "week_1")

    @property
    def delivery_type(self) -> str:
        return self.user_context.get("delivery_type", "unknown")

    @property
    def baby_name(self) -> str:
        return self.user_context.get("baby_name", "baby")

    @property
    def mood_history(self) -> list:
        return self.user_context.get("mood_history", [])

    @property
    def baby_data(self) -> dict:
        return self.user_context.get("baby_data", {})

    @property
    def has_image(self) -> bool:
        return self.image is not None