"""Smoke tests for multi-provider-ai MCP server."""

import importlib
import os
import sys


def test_server_imports():
    """Verify the server module can be imported without errors."""
    # Ensure the module path is available
    server_dir = os.path.dirname(os.path.abspath(__file__))
    if server_dir not in sys.path:
        sys.path.insert(0, server_dir)

    spec = importlib.util.spec_from_file_name(
        "server", os.path.join(server_dir, "server.py")
    )
    assert spec is not None, "server.py not found"
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    assert hasattr(mod, "mcp"), "FastMCP instance not found"


def test_vertex_endpoint_format():
    """Verify Vertex AI endpoint URL format."""
    server_dir = os.path.dirname(os.path.abspath(__file__))
    if server_dir not in sys.path:
        sys.path.insert(0, server_dir)

    # Set required env vars for test
    os.environ.setdefault("GCP_PROJECT", "test-project")
    os.environ.setdefault("GCP_REGION", "us-central1")

    spec = importlib.util.spec_from_file_name(
        "server", os.path.join(server_dir, "server.py")
    )
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)

    url = mod._vertex_endpoint("gemini-2.0-flash")
    assert "aiplatform.googleapis.com" in url
    assert "test-project" in url or "GCP_PROJECT" in url


def test_env_example_exists():
    """Verify .env.example exists with required variables."""
    env_path = os.path.join(os.path.dirname(__file__), ".env.example")
    assert os.path.exists(env_path), ".env.example not found"

    with open(env_path) as f:
        content = f.read()
    assert "GCP_PROJECT" in content
    assert "GCP_REGION" in content
