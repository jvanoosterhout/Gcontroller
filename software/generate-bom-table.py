#!/usr/bin/env python3
"""Generate the README BOM table from hardware/bom.csv."""

import argparse
import csv
from pathlib import Path


START_MARKER = "<!-- BOM:START -->"
END_MARKER = "<!-- BOM:END -->"


def markdown_link(component: str, url: str) -> str:
    return f"[{component}]({url})" if url else component


def build_table(rows: list[dict[str, str]]) -> str:
    lines = [
        "| Category | Component | Details | Qty | Status | Notes |",
        "|----------|-----------|---------|-----|--------|-------|",
    ]
    for row in rows:
        component = markdown_link(row["component"], row["url"])
        lines.append(
            "| {category} | {component} | {details} | {quantity} | {status} | {notes} |".format(
                category=row["category"],
                component=component,
                details=row["details"],
                quantity=row["quantity"],
                status=row["status"],
                notes=row["notes"],
            )
        )
    return "\n".join(lines)


def main() -> None:
    repo_root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bom", type=Path, default=repo_root / "hardware/bom.csv")
    parser.add_argument("--readme", type=Path, default=repo_root / "README.md")
    args = parser.parse_args()

    with args.bom.open(newline="", encoding="utf-8") as stream:
        rows = list(csv.DictReader(stream))

    required_columns = {"category", "component", "details", "quantity", "status", "notes", "url"}
    missing_columns = required_columns - set(rows[0]) if rows else required_columns
    if missing_columns:
        raise SystemExit(f"Missing BOM columns: {', '.join(sorted(missing_columns))}")

    readme = args.readme.read_text(encoding="utf-8")
    start = readme.find(START_MARKER)
    end = readme.find(END_MARKER)
    if start == -1 or end == -1 or end < start:
        raise SystemExit("README BOM markers are missing or out of order")

    replacement = f"{START_MARKER}\n\n{build_table(rows)}\n\n{END_MARKER}"
    updated = readme[:start] + replacement + readme[end + len(END_MARKER):]
    args.readme.write_text(updated, encoding="utf-8")


if __name__ == "__main__":
    main()