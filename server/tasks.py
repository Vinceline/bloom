"""
Bloom — Task Definitions
=========================
Declarative registry of every task the pipeline can execute.
Each task maps to an agent and an action within that agent.

The pipeline doesn't know about agents directly — it looks up
the task here, gets the agent class, and calls it.
"""

from dataclasses import dataclass
from typing import Type
from context import BloomContext



@dataclass
class Task:
    name: str                   # unique identifier, e.g. "mind.mood_checkin"
    pillar: str                 # which pillar this belongs to
    action: str                 # action name within the agent
    agent_module: str           # module path, e.g. "agents.mind_agent"
    agent_class: str            # class name, e.g. "MindAgent"
    description: str            # human-readable description (for debugging/logging)
    requires_image: bool = False


# ── Task Registry ──
# All tasks the pipeline knows about. Router picks one of these.

TASK_REGISTRY: dict[str, Task] = {}

def _register(task: Task):
    TASK_REGISTRY[task.name] = task

# --- Mind Tasks ---
_register(Task(
    name="mind.mood_checkin",
    pillar="mind",
    action="mood_checkin",
    agent_module="agents.mind_agent",
    agent_class="MindAgent",
    description="Process a mood check-in and provide supportive response"
))

_register(Task(
    name="mind.mood_analysis",
    pillar="mind",
    action="mood_analysis",
    agent_module="agents.mind_agent",
    agent_class="MindAgent",
    description="Analyze mood history trend, flag concerns gently"
))

_register(Task(
    name="mind.breathing_exercise",
    pillar="mind",
    action="breathing_exercise",
    agent_module="agents.mind_agent",
    agent_class="MindAgent",
    description="Guide the user through a breathing or grounding exercise"
))

_register(Task(
    name="mind.general_support",
    pillar="mind",
    action="general_support",
    agent_module="agents.mind_agent",
    agent_class="MindAgent",
    description="General emotional support and encouragement"
))

# --- Body Tasks ---
_register(Task(
    name="body.recovery_guidance",
    pillar="body",
    action="recovery_guidance",
    agent_module="agents.body_agent",
    agent_class="BodyAgent",
    description="Stage-appropriate physical recovery guidance"
))

_register(Task(
    name="body.photo_analysis",
    pillar="body",
    action="photo_analysis",
    agent_module="agents.body_agent",
    agent_class="BodyAgent",
    description="Analyze a photo of healing progress (e.g. C-section incision)",
    requires_image=True
))

_register(Task(
    name="body.exercise_recommendation",
    pillar="body",
    action="exercise_recommendation",
    agent_module="agents.body_agent",
    agent_class="BodyAgent",
    description="Recommend exercises based on delivery type and recovery stage"
))

_register(Task(
    name="body.symptom_check",
    pillar="body",
    action="symptom_check",
    agent_module="agents.body_agent",
    agent_class="BodyAgent",
    description="Assess described symptoms and advise whether to seek care"
))

# --- Baby Tasks ---
_register(Task(
    name="baby.cue_reading",
    pillar="baby",
    action="cue_reading",
    agent_module="agents.baby_agent",
    agent_class="BabyAgent",
    description="Read baby cues from a photo to determine state",
    requires_image=True
))

_register(Task(
    name="baby.feeding_guidance",
    pillar="baby",
    action="feeding_guidance",
    agent_module="agents.baby_agent",
    agent_class="BabyAgent",
    description="Feeding advice based on baby data and recovery stage"
))

_register(Task(
    name="baby.sleep_guidance",
    pillar="baby",
    action="sleep_guidance",
    agent_module="agents.baby_agent",
    agent_class="BabyAgent",
    description="Sleep pattern guidance for the newborn"
))

_register(Task(
    name="baby.general_baby_support",
    pillar="baby",
    action="general_baby_support",
    agent_module="agents.baby_agent",
    agent_class="BabyAgent",
    description="General newborn care questions"
))

# --- Partner Tasks ---
_register(Task(
    name="partner.help_suggestion",
    pillar="partner",
    action="help_suggestion",
    agent_module="agents.partner_agent",
    agent_class="PartnerAgent",
    description="Context-aware suggestion for how partner can help right now"
))

_register(Task(
    name="partner.emotional_support",
    pillar="partner",
    action="emotional_support",
    agent_module="agents.partner_agent",
    agent_class="PartnerAgent",
    description="Guidance on providing emotional support to the mother"
))

_register(Task(
    name="partner.feeding_help",
    pillar="partner",
    action="feeding_help",
    agent_module="agents.partner_agent",
    agent_class="PartnerAgent",
    description="How the partner can help with feeding and baby care"
))

_register(Task(
    name="partner.general_partner_support",
    pillar="partner",
    action="general_partner_support",
    agent_module="agents.partner_agent",
    agent_class="PartnerAgent",
    description="General support and encouragement for the partner"
))

def heartbeat(context: BloomContext):
    """
    Periodic reevaluation task.
    Allows Gemini to notice drift even without new input.
    """
    from pipeline import run_pipeline
    run_pipeline({
        "message": "",
        "context": context.user_context
    })


def get_task(pillar: str, action: str) -> Task | None:
    """Look up a task by pillar + action. Returns None if not found."""
    key = f"{pillar}.{action}"
    return TASK_REGISTRY.get(key)


def get_tasks_for_pillar(pillar: str) -> list[Task]:
    """All tasks for a given pillar."""
    return [t for t in TASK_REGISTRY.values() if t.pillar == pillar]


def all_task_names() -> list[str]:
    """All registered task names — useful for the router prompt."""
    return list(TASK_REGISTRY.keys())