"""
Bloom — Flask Server
=====================
Thin HTTP layer. Receives requests, hands them to the pipeline,
streams the pipeline's SSE output back to the client.

No business logic lives here. No prompts. No Gemini calls.
This file only knows about HTTP.

SETUP:
  1. .env file in this directory:
         GEMINI_API_KEY=your_key_here

  2. Install dependencies:
         pip install flask flask-cors google-genai python-dotenv Pillow

  3. Run:
         python server.py

  Listens on http://0.0.0.0:8080
"""

from flask import Flask, request, Response, jsonify
from flask_cors import CORS
from pipeline import run_pipeline

app = Flask(__name__)
CORS(app)


@app.route("/health", methods=["GET"])
def health():
    """Quick connectivity check from the iOS app."""
    return jsonify({"status": "ok", "app": "bloom"})


@app.route("/bloom", methods=["POST"])
def bloom():
    """
    Main endpoint. Expects JSON:
      {
        "message":    "...",
        "pillar":     "mind" | "body" | "baby" | "partner" | null,
        "context":    { ...UserProfile context from iOS... },
        "image_data": "base64..." | null
      }

    Returns SSE stream. Events:
      status  → { message }
      routed  → { pillar, action, reasoning }
      result  → BloomResponse JSON
      error   → { error }
    """
    body = request.get_json(force=True, silent=True) or {}

    return Response(
        run_pipeline(body),
        mimetype="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
        }
    )


if __name__ == "__main__":
    print("\n🌸 Bloom server starting...")
    print("   Endpoint: POST http://0.0.0.0:8080/bloom\n")
    app.run(host="0.0.0.0", port=8080, debug=False)