#!/usr/bin/env python3
"""Claude Code PreToolUse hook (Bash): keep secrets out of transcripts.

Denies commands that would print decrypted sekrets files (git's textconv
decrypts `.enc` files on diff/show/log -p) and asks before running a command
that carries a key-shaped literal or dumps the whole environment.

Why: secrets reached agent transcripts in 5 to 7 sessions a month in
Jul/Aug/Oct 2026 (sekrets `git diff`, API keys expanded on command lines).
Limit: a bare `git diff` with no path in a repo holding `.enc` files is not
detectable from the command text; this guard covers the explicit cases.
"""
import json
import re
import sys

ENC_PATH = re.compile(r"(\S*\.enc\b|\bsekrets\b)")
READ_VERB = re.compile(
    r"\b(git\s+(diff|show|log\b[^|;&]*-p|blame|cat-file)|cat|bat|less|more|head|tail|strings|xxd|hexdump|od|sed|awk|cut)\b"
)
SAFE_READ = re.compile(r"(--no-textconv|--stat|--name-only|--name-status|--textconv\s+-c|grep\s[^|;&]*-c)")

KEY_PATTERNS = [
    (r"\bAKIA[0-9A-Z]{16}\b", "AWS access key ID"),
    (r"\b(ghp|gho|ghs|ghu)_[A-Za-z0-9]{30,}\b|\bgithub_pat_[A-Za-z0-9_]{40,}", "GitHub token"),
    (r"\bsk-[A-Za-z0-9_-]{20,}", "API secret key (sk-...)"),
    (r"\bxox[abprs]-[A-Za-z0-9-]{10,}", "Slack token"),
    (r"-----BEGIN [A-Z ]*PRIVATE KEY-----", "private key"),
    (
        r"(?i)\b(api[_-]?key|access[_-]?token|auth[_-]?token|secret|password|passwd)\b\s*[=:]\s*['\"]?[A-Za-z0-9_/+.\-]{16,}",
        "credential assignment",
    ),
    (r"(?i)(x-api-key|authorization):\s*(bearer\s+)?[A-Za-z0-9_\-.]{20,}", "credential in a header"),
]
ENV_DUMP = re.compile(r"(^|[|;&]\s*)(env|printenv|set)\s*($|[|;&>])")


def decide(command: str):
    if ENC_PATH.search(command) and READ_VERB.search(command) and not SAFE_READ.search(command):
        return "deny", (
            "Blocked: this would print a sekrets/.enc file, and git textconv decrypts it into the "
            "transcript. Use `git grep --textconv -c <key>` for presence checks, "
            "`git diff --stat` for scope, or mask values with `sed 's/=.*/=<masked>/'`."
        )
    for pattern, label in KEY_PATTERNS:
        if re.search(pattern, command):
            return "ask", (
                f"This command contains what looks like a {label}. Literal secrets on a command line "
                "land in the transcript and shell history. Read it from a file or env var inside the "
                "command instead."
            )
    if ENV_DUMP.search(command) and not re.search(r"\b(env|printenv)\s*\|\s*grep\b", command):
        return "ask", "This prints the whole environment, which usually includes tokens. Print only the variable you need."
    return None, None


def main():
    try:
        payload = json.load(sys.stdin)
    except json.JSONDecodeError:
        return 0
    command = (payload.get("tool_input") or {}).get("command") or ""
    decision, reason = decide(command)
    if decision:
        json.dump(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": decision,
                    "permissionDecisionReason": reason,
                }
            },
            sys.stdout,
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())
