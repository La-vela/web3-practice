"""
morning.py
매일 새벽 Web3 학습 세션을 시작/종료하는 스크립트

사용법:
  python scripts/morning.py          # 세션 시작 (노트 생성 + 어제 복습)
  python scripts/morning.py --done   # 세션 종료 (git add/commit/push)
"""

import os
import re
import sys
import subprocess
from datetime import datetime, timedelta
from pathlib import Path

if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")

ROOT = Path(__file__).parent.parent
NOTES_DIR = ROOT / "notes"
TEMPLATE_PATH = NOTES_DIR / "TEMPLATE.md"

TODAY = datetime.now()
TODAY_STR = TODAY.strftime("%Y-%m-%d")
YESTERDAY_STR = (TODAY - timedelta(days=1)).strftime("%Y-%m-%d")


def note_path(date_str: str) -> Path:
    y, m, _ = date_str.split("-")
    return NOTES_DIR / y / m / f"{date_str}.md"


def make_today_note() -> Path:
    path = note_path(TODAY_STR)
    if path.exists():
        return path

    path.parent.mkdir(parents=True, exist_ok=True)
    template = TEMPLATE_PATH.read_text(encoding="utf-8")

    # Day 번호: notes/ 아래 날짜 파일 개수 + 1
    existing = sorted(NOTES_DIR.rglob("[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].md"))
    day_num = len(existing) + 1

    content = template.replace("YYYY-MM-DD", TODAY_STR).replace("Day N", f"Day {day_num}")
    path.write_text(content, encoding="utf-8")
    return path


def print_banner():
    week_num = TODAY.isocalendar()[1]
    day_name = ["월", "화", "수", "목", "금", "토", "일"][TODAY.weekday()]
    print()
    print("=" * 56)
    print(f"  WEB3 MORNING SESSION  |  {TODAY_STR} ({day_name})  |  W{week_num}")
    print("=" * 56)


def show_yesterday():
    path = note_path(YESTERDAY_STR)
    if not path.exists():
        print(f"\n[어제 노트 없음] {YESTERDAY_STR}")
        return

    lines = path.read_text(encoding="utf-8").splitlines()
    print(f"\n--- 어제 복습 ({YESTERDAY_STR}) ---")

    # 핵심 개념 섹션만 추출
    in_section = False
    printed = 0
    for line in lines:
        if line.startswith("## 핵심 개념"):
            in_section = True
            continue
        if in_section:
            if line.startswith("## ") and "핵심 개념" not in line:
                break
            if line.strip():
                print(" ", line)
                printed += 1
                if printed >= 8:
                    print("  ...")
                    break

    if printed == 0:
        # 핵심 개념이 비어있으면 첫 몇 줄만
        for line in lines[:6]:
            if line.strip():
                print(" ", line)


def print_checklist(note_path: Path):
    rel = note_path.relative_to(ROOT)
    print(f"\n--- 오늘 노트: {rel} ---")
    print()
    print("  [ ] Phase 1  어제 노트 복습           (2~3분)")
    print("  [ ] Phase 2  HackQuest 레슨 + 코딩   (10~15분)")
    print("  [ ] Phase 3  노트 핵심 개념 기록       (5분)")
    print("  [ ] Phase 4  코드 변형 / 질문 메모     (선택)")
    print()
    print("  >>> 노트 작성 후: python scripts/morning.py --done")
    print()


def session_done():
    print()
    print("=" * 56)
    print("  세션 종료 — git commit & push")
    print("=" * 56)

    os.chdir(ROOT)

    # 스테이징
    subprocess.run(["git", "add", "notes/", "code/"], check=True)

    status = subprocess.run(
        ["git", "diff", "--cached", "--name-only"],
        capture_output=True, text=True
    )
    changed_files = status.stdout.strip()

    if not changed_files:
        print("\n변경된 파일 없음. 노트를 먼저 작성해주세요.")
        return

    print("\n스테이징된 파일:")
    for f in changed_files.splitlines():
        print(f"  + {f}")

    commit_msg = f"study: {TODAY_STR} Web3 학습 노트"
    subprocess.run(["git", "commit", "-m", commit_msg], check=True)

    # push (origin/main 존재 시)
    remotes = subprocess.run(
        ["git", "remote"], capture_output=True, text=True
    ).stdout.strip()

    if "origin" in remotes:
        subprocess.run(["git", "push", "origin", "main"], check=True)
        print("\n[완료] GitHub에 푸시 되었습니다.")
    else:
        print("\n[완료] 로컬 커밋 완료 (원격 없음).")

    print()


def main():
    if "--done" in sys.argv:
        session_done()
        return

    print_banner()
    show_yesterday()
    path = make_today_note()

    created = not note_path(TODAY_STR).exists() if False else True  # already created above
    status = "[생성됨]" if "Day" in path.read_text(encoding="utf-8").splitlines()[0] else "[기존]"
    print(f"\n{status} {path.relative_to(ROOT)}")

    print_checklist(path)


if __name__ == "__main__":
    main()
