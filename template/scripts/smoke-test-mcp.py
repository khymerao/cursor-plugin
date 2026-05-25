#!/usr/bin/env python3
"""Smoke test for MCP server — run after setup.sh."""

from __future__ import annotations

import asyncio
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "mcp"))

from server import mcp  # noqa: E402


async def main() -> None:
    tools = await mcp.list_tools()
    names = [t.name for t in tools]
    print("tools:", names)
    if not names:
        raise SystemExit("No tools registered")
    print("smoke test passed")


if __name__ == "__main__":
    asyncio.run(main())
