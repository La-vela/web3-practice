"""
weekly_status.py
HackQuest 학습 노트(.md)를 날짜별로 집계하여 README.md의
<!-- HACKQUEST_WEEKLY:START --> ~ <!-- HACKQUEST_WEEKLY:END --> 블록을 업데이트합니다.

사용법:
  python weekly_status.py              # 집계 결과만 출력
  python weekly_status.py --update-readme  # README.md 자동 업데이트
"""

import os
import re
import sys
from datetime import datetime, timedelta
from pathlib import Path
from collections import defaultdict

# Windows CP949 환경에서 Unicode 출력 보장
if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")

NOTES_DIR = Path(__file__).parent.parent / "notes"
README_PATH = Path(__file__).parent.parent / "README.md"

START_MARKER = "<!-- HACKQUEST_WEEKLY:START -->"
END_MARKER = "<!-- HACKQUEST_WEEKLY:END -->"

MAX_BAR = 10   # 그래프 최대 블록 수
SHOW_WEEKS = 12


def iso_week_label(date: datetime) -> str:
    return date.strftime("%G-W%V")


def collect_notes() -> dict[str, int]:
    """notes/ 아래 YYYY-MM-DD.md 파일을 탐색해 주차별 카운트 반환."""
    weekly: dict[str, int] = defaultdict(int)
    date_pattern = re.compile(r"^\d{4}-\d{2}-\d{2}\.md$")

    for md_file in NOTES_DIR.rglob("*.md"):
        if md_file.name == "TEMPLATE.md":
            continue
        if date_pattern.match(md_file.name):
            date_str = md_file.stem  # YYYY-MM-DD
            try:
                date = datetime.strptime(date_str, "%Y-%m-%d")
                week_label = iso_week_label(date)
                weekly[week_label] += 1
            except ValueError:
                continue

    return weekly


def build_table(weekly: dict[str, int], show_weeks: int = SHOW_WEEKS) -> str:
    """주차별 집계 테이블 문자열 생성."""
    # 최근 show_weeks 주 범위 계산
    today = datetime.now()
    weeks = []
    for i in range(show_weeks - 1, -1, -1):
        d = today - timedelta(weeks=i)
        weeks.append(iso_week_label(d))

    lines = []
    lines.append("| Week | Count | Graph |")
    lines.append("|------|-------|-------|")

    for week in weeks:
        count = weekly.get(week, 0)
        if count == 0:
            bar = ""
        else:
            max_count = max(weekly.values()) if weekly else 1
            bar_len = max(1, round(count / max_count * MAX_BAR))
            bar = "█" * bar_len

        lines.append(f"| {week} | {count:>5} | {bar} |")

    lines.append("")
    lines.append("> 매주 일요일 오전 9시 GitHub Action을 통해 자동 집계됩니다.")
    return "\n".join(lines)


def update_readme(table: str) -> None:
    """README.md의 마커 사이 내용을 교체."""
    content = README_PATH.read_text(encoding="utf-8")

    pattern = re.compile(
        rf"{re.escape(START_MARKER)}.*?{re.escape(END_MARKER)}",
        re.DOTALL,
    )
    replacement = f"{START_MARKER}\n\n{table}\n\n{END_MARKER}"

    if not pattern.search(content):
        print("[ERROR] README.md에서 마커를 찾을 수 없습니다.")
        sys.exit(1)

    new_content = pattern.sub(replacement, content)
    README_PATH.write_text(new_content, encoding="utf-8")
    print("[OK] README.md 업데이트 완료.")


def main():
    weekly = collect_notes()
    table = build_table(weekly)

    print("\n=== HackQuest 주간 학습 현황 ===\n")
    print(table)
    print()

    if "--update-readme" in sys.argv:
        update_readme(table)


if __name__ == "__main__":
    main()
