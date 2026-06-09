#!/usr/bin/env python3
"""
Exhaustive configuration tester for EC17 masking repository.

Strategy
--------
Phase 1 – DFS enumeration:
    Drive configure.py as a black box. At each interactive prompt, probe
    candidate answers (1, 2, 3, …) and observe whether configure.py rejects
    the answer ("Invalid input" in its stdout) or accepts it and either asks
    another question or exits cleanly. This produces the complete list of
    valid input sequences without any hard-coded knowledge of the menu tree.

Phase 2 – Parallel execution:
    Each configuration is run in its own temporary directory (a full copy of
    the project tree) so that concurrent workers never race on Makefile /
    param.h.

Usage
-----
    python3 test_all_configs.py [options]

Options
    --project-dir DIR   Root of the EC17 project to copy (default: .)
    --dry-run           Print enumerated configs, skip make.
    --jobs N            Parallel workers (default: 1).
    --filter REGEX      Only run configs whose input-sequence label matches.
    --stop-on-fail      Stop at first failure.
    --log-dir DIR       Where to write per-config logs (default: ./logs).
    --max-depth N       Safety cap on DFS depth (default: 20).
    --max-choice N      Maximum choice index tried per prompt (default: 20).
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ProcessPoolExecutor, as_completed
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional, Tuple

# ──────────────────────────────────────────────────────────────────────────────
# Constants
# ──────────────────────────────────────────────────────────────────────────────

INVALID_MARKER  = "Invalid input"   # substring printed by configure.py on bad input
CONFIGURE_SCRIPT = "configure.py"

# ──────────────────────────────────────────────────────────────────────────────
# Data
# ──────────────────────────────────────────────────────────────────────────────

@dataclass
class Config:
    inputs: List[str]   # full answer sequence fed to configure.py
    label: str = ""     # derived from inputs, e.g. "1-3-2-1-2"

    def __post_init__(self):
        if not self.label:
            self.label = "-".join(self.inputs)


@dataclass
class Result:
    config: Config
    configure_ok: bool = False
    build_ok: bool = False
    test_ok: bool = False
    elapsed: float = 0.0
    log_path: str = ""
    error_msg: str = ""


# ──────────────────────────────────────────────────────────────────────────────
# Phase 1 – DFS enumeration
# ──────────────────────────────────────────────────────────────────────────────

def _run_configure(configure_path: Path, inputs: List[str]) -> Tuple[int, str]:
    """Run configure.py with the given inputs; return (returncode, stdout+stderr)."""
    stdin_data = "\n".join(inputs) + "\n"
    try:
        proc = subprocess.run(
            [sys.executable, str(configure_path)],
            input=stdin_data,
            capture_output=True,
            text=True,
            timeout=10,
        )
        return proc.returncode, proc.stdout + proc.stderr
    except subprocess.TimeoutExpired:
        return -1, ""


def _probe(configure_path: Path, inputs: List[str]) -> Tuple[bool, bool]:
    """
    Determine whether `inputs` is a valid prefix (or complete leaf) for the
    configure.py menu tree.

    Returns (accepted, finished):
        accepted  – the last answer in `inputs` was not rejected.
        finished  – configure.py exited cleanly after consuming all inputs
                    (i.e. `inputs` is a complete leaf configuration).

    Algorithm
    ---------
    We run configure.py twice:

    Run A – with `inputs` only (no sentinel).
      • If it exits 0  → finished leaf (accepted=True, finished=True).
      • If it exits non-0 and output contains INVALID_MARKER
                       → last answer rejected (accepted=False, finished=False).
      • If it exits non-0 without INVALID_MARKER (e.g. waiting for more input
        via a blocking read that never came because stdin closed)
                       → internal node, answers accepted so far.

    In the "internal node" case we additionally run:
    Run B – with `inputs + ["999"]` (a sentinel that will always be rejected
    by configure.py's range checks).
      • If output contains INVALID_MARKER → confirmed that configure.py was
        indeed waiting for input and rejected our out-of-range sentinel.
        (accepted=True, finished=False).
      • Otherwise something unexpected happened; treat as rejected.
    """
    rc_a, out_a = _run_configure(configure_path, inputs)

    # Clean exit → complete configuration.
    if rc_a == 0:
        return True, True

    # configure.py died/blocked and the last answer was invalid.
    if INVALID_MARKER in out_a:
        return False, False

    # configure.py stopped without printing INVALID_MARKER and without a clean
    # exit: it was waiting for more input (stdin EOF caused it to crash/return
    # non-zero).  Confirm with a sentinel.
    _, out_b = _run_configure(configure_path, inputs + ["999"])
    if INVALID_MARKER in out_b:
        return True, False   # internal node, inputs accepted

    # Unexpected situation – skip this branch.
    return False, False


def dfs_enumerate(
    configure_path: Path,
    max_depth: int = 20,
    max_choice: int = 20,
    verbose: bool = True,
) -> List[Config]:
    """
    DFS over configure.py's interactive menu tree.
    Returns the list of all complete (leaf) input sequences.
    """
    leaves: List[Config] = []

    # Stack of input-sequence prefixes to expand, seeded with the empty prefix.
    stack: List[List[str]] = [[]]
    nodes_visited = 0

    while stack:
        current = stack.pop()

        if len(current) >= max_depth:
            print(f"  [DFS] WARNING: max depth {max_depth} at {current}, skipping subtree",
                  file=sys.stderr)
            continue

        found_any_child = False
        for choice in range(1, max_choice + 1):
            candidate = current + [str(choice)]
            nodes_visited += 1
            accepted, finished = _probe(configure_path, candidate)

            if not accepted:
                # Menus are always 1..N contiguous, so once we hit a rejection
                # after finding valid children we can stop probing higher values.
                if found_any_child:
                    break
                continue   # keep trying if we haven't seen any valid child yet

            found_any_child = True

            if finished:
                leaves.append(Config(inputs=candidate))
                if verbose:
                    print(f"  [DFS] leaf found: {'-'.join(candidate)}  "
                          f"(total so far: {len(leaves)})", flush=True)
            else:
                # Push for further DFS expansion.  Append to stack so that
                # deeper nodes are explored first (true DFS).
                stack.append(candidate)

    if verbose:
        print(f"  [DFS] {nodes_visited} nodes probed, {len(leaves)} leaves found.")
    return leaves


# ──────────────────────────────────────────────────────────────────────────────
# Phase 2 – Run one configuration in an isolated temp directory
# ──────────────────────────────────────────────────────────────────────────────

def run_config(
    config: Config,
    project_dir: Path,
    log_dir: Path,
) -> Result:
    result = Result(config=config)
    log_path = log_dir / f"{config.label}.log"
    result.log_path = str(log_path)

    t0 = time.monotonic()
    tmp_dir = Path(tempfile.mkdtemp(prefix="ec17_"))
    try:
        # Isolated copy of the whole project so parallel workers don't collide.
        work_dir = tmp_dir / "project"
        shutil.copytree(
            project_dir,
            work_dir,
            ignore=shutil.ignore_patterns(".git", "__pycache__", "*.pyc", "logs"),
        )

        with open(log_path, "w") as logf:
            def _run(cmd: str, stdin_data: Optional[str] = None) -> subprocess.CompletedProcess:
                proc = subprocess.run(
                    cmd, shell=True, text=True,
                    input=stdin_data,
                    capture_output=True, 
                    cwd=work_dir,
                )
                out = proc.stdout + proc.stderr
                logf.write(out)
                return proc, out

            # 1. Configure
            configure_input = "\n".join(config.inputs) + "\n"
            logf.write(f"=== inputs: {config.inputs} ===\n\n")
            r, out = _run(f"{sys.executable} {CONFIGURE_SCRIPT}", stdin_data=configure_input)
            if r.returncode != 0:
                result.error_msg = "configure.py failed"
                result.elapsed = time.monotonic() - t0
                return result
            result.configure_ok = True

            # Cortex-A test
            # 2. Build
            r, out = _run("make clean && PLATFORM=cortexa make")
            if r.returncode != 0:
                result.error_msg = "build failed"
                result.elapsed = time.monotonic() - t0
                return result
            result.build_ok = True
            # 3. Test
            r, out = _run("PLATFORM=cortexa make platform_test")
            if r.returncode != 0 or ("Test NOK" in out) or ("Test successfull" not in out):
                result.error_msg = "platform_test failed"
                result.elapsed = time.monotonic() - t0
                return result
            result.test_ok = True

            # Cortex-M4 test
            # 2. Build
            r, out = _run("make clean && PLATFORM=cortexm4 make")
            if r.returncode != 0:
                result.error_msg = "build failed"
                result.elapsed = time.monotonic() - t0
                return result
            result.build_ok = True
            # 3. Test
            r, out = _run("PLATFORM=cortexm4 make platform_test")
            if r.returncode != 0 or ("Test NOK" in out) or ("Test successfull" not in out):
                result.error_msg = "platform_test failed"
                result.elapsed = time.monotonic() - t0
                return result
            result.test_ok = True

    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

    result.elapsed = time.monotonic() - t0
    return result


# ──────────────────────────────────────────────────────────────────────────────
# Reporting
# ──────────────────────────────────────────────────────────────────────────────

GREEN = "\033[32m"
RED   = "\033[31m"
RESET = "\033[0m"


def status_str(r: Result) -> str:
    if r.test_ok:
        return f"{GREEN}PASS{RESET} [{' -> '.join(r.config.inputs)}]"
    stage = "configure" if not r.configure_ok else ("build" if not r.build_ok else "test")
    return f"{RED}FAIL({stage}){RESET}  [{' -> '.join(r.config.inputs)}]"


def print_result(r: Result):
    t = f"  ({r.elapsed:.1f}s)" if r.elapsed else ""
    print(f"[{status_str(r)}] {r.config.label}{t}")
    if not r.test_ok:
        print(f"        error : {r.error_msg}")
        print(f"        log   : {r.log_path}")
        if r.log_path and os.path.exists(r.log_path):
            print("        ── log dump ──────────────────────────")
            with open(r.log_path) as f:
                for line in f:
                    print(f"        {line}", end="")
            print("        ──────────────────────────────────────")


def print_summary(results: List[Result]):
    total  = len(results)
    passed = sum(1 for r in results if r.test_ok)
    failed = total - passed
    print("\n" + "═" * 72)
    print(f"  SUMMARY : {passed}/{total} passed  |  {failed} failed")
    print("═" * 72)
    for r in results:
        icon = "✓" if r.test_ok else "✗"
        t    = f"{r.elapsed:.1f}s" if r.elapsed else ""
        print(f"  {icon} [{status_str(r)}] {r.config.label}  {t}")
        if not r.test_ok and r.log_path:
            print(f"       log → {r.log_path}")
    print()


# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────

def main() -> int:
    parser = argparse.ArgumentParser(
        description="Exhaustive EC17 config tester (DFS + isolated temp dirs)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("--project-dir", default=".", metavar="DIR",
                        help="Root of the EC17 project (default: .)")
    parser.add_argument("--dry-run", action="store_true",
                        help="Enumerate configs and print them; skip make")
    parser.add_argument("--jobs", type=int, default=1, metavar="N",
                        help="Parallel workers (default: 1)")
    parser.add_argument("--filter", metavar="REGEX", default=None,
                        help="Only run configs whose label matches this regex")
    parser.add_argument("--stop-on-fail", action="store_true",
                        help="Stop at first failure")
    parser.add_argument("--log-dir", default="logs", metavar="DIR",
                        help="Per-config log directory (default: ./logs)")
    parser.add_argument("--max-depth", type=int, default=20, metavar="N",
                        help="DFS safety cap on menu depth (default: 20)")
    parser.add_argument("--max-choice", type=int, default=20, metavar="N",
                        help="Max choice index probed per prompt (default: 20)")
    args = parser.parse_args()

    project_dir = Path(args.project_dir).resolve()
    configure_path = project_dir / CONFIGURE_SCRIPT
    if not configure_path.exists():
        print(f"ERROR: {configure_path} not found.", file=sys.stderr)
        return 1

    log_dir = Path(args.log_dir)
    log_dir.mkdir(parents=True, exist_ok=True)

    # ── Phase 1: DFS enumeration ──────────────────────────────────────────────
    print(f"Phase 1 — Enumerating configurations via DFS on {configure_path} …")
    t0 = time.monotonic()
    all_configs = dfs_enumerate(
        configure_path,
        max_depth=args.max_depth,
        max_choice=args.max_choice,
        verbose=True,
    )
    print(f"Enumeration done in {time.monotonic() - t0:.1f}s  →  {len(all_configs)} configurations\n")

    if args.filter:
        pattern = re.compile(args.filter)
        all_configs = [c for c in all_configs if pattern.search(c.label)]
        print(f"After filter '{args.filter}': {len(all_configs)} configurations\n")

    if not all_configs:
        print("No configurations to run.")
        return 0

    if args.dry_run:
        print("Phase 2 — dry-run (no make):")
        for c in all_configs:
            print(f"  {c.label}")
        return 0

    # ── Phase 2: build + test ─────────────────────────────────────────────────
    print(f"Phase 2 — Running {len(all_configs)} configurations "
          f"({'parallel x' + str(args.jobs) if args.jobs > 1 else 'sequential'}) …\n")

    results: List[Result] = []
    stop = False

    if args.jobs == 1:
        for cfg in all_configs:
            r = run_config(cfg, project_dir, log_dir)
            results.append(r)
            print_result(r)
            if args.stop_on_fail and not r.test_ok:
                print("Stopping on first failure.")
                break
    else:
        with ProcessPoolExecutor(max_workers=args.jobs) as pool:
            futures = {
                pool.submit(run_config, cfg, project_dir, log_dir): cfg
                for cfg in all_configs
            }
            try:
                for fut in as_completed(futures):
                    r = fut.result()
                    results.append(r)
                    print_result(r)
                    if args.stop_on_fail and not r.test_ok:
                        print("Stopping on first failure.")
                        for f in futures:
                            f.cancel()
                        break
            except KeyboardInterrupt:
                print("\nInterrupted by user.")

    print_summary(results)
    return 1 if any(not r.test_ok for r in results) else 0


if __name__ == "__main__":
    sys.exit(main())
