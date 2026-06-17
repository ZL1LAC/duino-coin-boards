#!/usr/bin/env python3
"""Read boards/registry.json — used by firmware build scripts."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "boards" / "registry.json"


def load_registry() -> dict:
    with REGISTRY.open(encoding="utf-8") as f:
        return json.load(f)


def get_board(board_id: str) -> dict:
    for board in load_registry()["boards"]:
        if board["id"] == board_id:
            return board
    raise KeyError(f"unknown board id: {board_id}")


def firmware_board_ids() -> list[str]:
    return [
        b["id"]
        for b in load_registry()["boards"]
        if b.get("firmware", {}).get("enabled")
    ]


def main() -> None:
    if len(sys.argv) < 2:
        raise SystemExit("usage: registry.py <list|get> [board_id]")

    cmd = sys.argv[1]
    if cmd == "list":
        print("\n".join(firmware_board_ids()))
    elif cmd == "get":
        board_id = sys.argv[2]
        print(json.dumps(get_board(board_id), indent=2))
    else:
        raise SystemExit(f"unknown command: {cmd}")


if __name__ == "__main__":
    main()
