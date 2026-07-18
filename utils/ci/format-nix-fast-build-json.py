import json
import os
import sys

from collections import defaultdict
from dataclasses import dataclass, field
from functools import cached_property
from typing import DefaultDict, Self


def cli() -> [dict]:
    if len(sys.argv) > 1 and sys.argv[1] in ("-h", "--help"):
        print("Usage: python3 script.py [FILE|-]")
        print("Reads nix-fast-build JSON output and formats it as a table.")
        print("If no file is specified or '-' is passed, reads from stdin.")
        sys.exit(0)

    if len(sys.argv) < 2 or sys.argv[1] == "-":
        try:
            data = json.load(sys.stdin)
        except Exception as e:
            print(f"❌ Error reading JSON from stdin: {e}")
            sys.exit(1)
    else:
        json_file = sys.argv[1]
        if not os.path.exists(json_file):
            print(f"❌ {json_file} not found.")
            sys.exit(0)
        with open(json_file, "r") as f:
            data = json.load(f)

    return data.get("results", [])


def detect_present_stages(raw: [dict]) -> [str]:
    found_stages = {rtype for r in raw if (rtype := r.get("type")) is not None}

    # Establish column order
    preferred_order = [
        "EVAL",
        "BUILD",
        "ATTIC",
        "CACHIX",
        "UPLOAD",
        "DOWNLOAD",
        "NIKS3",
    ]
    stages_to_show = [
        *preferred_order[:2],  # anchors
        *(p for p in preferred_order[2:] if p in found_stages),  # well-known
        *(s for s in sorted(found_stages) if s not in preferred_order),  # unexpected
    ]

    return stages_to_show


@dataclass
class Attr:
    name: str
    success: bool = True
    fail_stages: {str: str} = field(
        default_factory=lambda: {}
    )  # Failed stages with their logs
    durations: DefaultDict[str, float] = field(
        default_factory=lambda: defaultdict(float)
    )

    @classmethod
    def from_raw(cls, raw: [dict]) -> [Self]:
        attrs = {}
        for entry in raw:
            if (name := entry.get("attr")) is None:
                continue

            attr = attrs.setdefault(name, cls(name=name))

            stage = entry.get("type", "UNKNOWN")
            success = entry.get("success", True)
            duration = entry.get("duration", 0.0)

            attr.success &= success
            # Add instead of assign to have accurate sum in case of unexpectedly repeated stages
            attr.durations[stage] += duration

            if not success:
                error = entry.get("error")
                attr.fail_stages[stage] = error

        return sorted(attrs.values(), key=lambda x: x.name)

    def columns(self, stage_order: [str]) -> [str]:
        total = sum(self.durations.values())

        if self.success:
            status = "✅ OK"
        else:
            failed = list(self.fail_stages.keys())
            status = "❌ Fail" if not failed else f"❌ Fail ({','.join(failed)})"

        return [
            status,
            self.name,
            *(f"{self.durations[s]:.2f}" for s in stage_order),
            f"{total:.2f}",
        ]


@dataclass
class Summary:
    items: int
    total: float
    stage_totals: DefaultDict[str, float] = field(
        default_factory=lambda: defaultdict(float)
    )

    @classmethod
    def from_results(cls, results: [Attr]) -> Self:
        total = 0.0
        stage_totals = defaultdict(float)

        for attr in results:
            for stage, duration in attr.durations.items():
                stage_totals[stage] += duration
                total += duration

        return cls(
            items=len(results),
            total=total,
            stage_totals=stage_totals,
        )

    def columns(self, stage_order: [str]) -> [str]:
        return [
            "📊 Summary",
            f"({self.items} items)",
            *(f"{self.stage_totals[s]:.2f}" for s in stage_order),
            f"{self.total:.2f}",
        ]


def display_width(s):
    s_str = str(s)
    w = len(s_str)
    # Emojis render as 2 spaces wide in standard mono-terminals.
    for c in s_str:
        if c in "📊✅❌":
            w += 1
    return w


@dataclass
class Table:
    stages_to_show: [str]
    data: [Attr]
    summary: Summary
    col_widths: [int]

    @classmethod
    def from_results(cls, stages_to_show: [str], results: [Attr]) -> Self:
        this = cls(
            stages_to_show=stages_to_show,
            data=results,
            summary=Summary.from_results(results),
            col_widths=[],
        )

        this.col_widths = [
            max(display_width(item) for item in col) for col in zip(*this.all_rows)
        ]

        return this

    @cached_property
    def header_row(self) -> [str]:
        return [
            "Status",
            "Attribute",
            *(f"{s.capitalize()} (s)" for s in self.stages_to_show),
            "Total (s)",
        ]

    @cached_property
    def summary_row(self) -> [str]:
        return self.summary.columns(self.stages_to_show)

    @cached_property
    def data_rows(self) -> [[str]]:
        return [d.columns(self.stages_to_show) for d in self.data]

    @cached_property
    def all_rows(self) -> [[str]]:
        return [self.header_row, self.summary_row, *self.data_rows]

    def failed_attr_info(self) -> [[str, str, str]]:
        return [
            [data.name, stage, error]
            for data in self.data
            for stage, error in data.fail_stages.items()
        ]

    def format(self, row: [str]) -> str:
        formatted = []
        for i, item in enumerate(row):
            pad_len = self.col_widths[i] - display_width(item)
            if i < 2:
                formatted.append(item + " " * pad_len)  # Left align text
            else:
                formatted.append(" " * pad_len + item)  # Right align numbers
        return " | ".join(formatted)

    def print(self):
        # Separator matched exactly to formatting spacing
        separator = "-+-".join("-" * w for w in self.col_widths)

        print(self.format(self.header_row))
        print(separator)
        print(self.format(self.summary_row))
        print(separator)
        for row in self.data_rows:
            print(self.format(row))

        if not all(data.success for data in self.data):
            print("\n" + "=" * 50)
            print("❌ FAILURE LOGS")
            print("=" * 50 + "\n")
            for attr, stage, error in self.failed_attr_info():
                print(f"::group::{attr} ({stage} failed)")
                if error != "":
                    print(error)
                else:
                    print("No error log provided in JSON.")
            print("::endgroup::")


def main():
    raw_data = cli()

    stages_to_show = detect_present_stages(raw_data)
    results = Attr.from_raw(raw_data)

    table = Table.from_results(stages_to_show, results)
    table.print()


if __name__ == "__main__":
    main()
