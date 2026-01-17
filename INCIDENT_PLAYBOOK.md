# FIM Alert Playbook (SOC Workflow)

## Goal
Use FIM output (Created/Modified/Deleted) to identify suspicious changes and decide when to escalate.

## Triage Loop
1. Validate: Confirm the path, file type, and hash change.
2. Scope: Check if similar changes happened elsewhere (same extension, same directory, same timeframe).
3. Impact: Identify if the file is in a high-risk location (Startup/System directories) or a high-risk type (.ps1/.exe/.dll).
4. Contain/Escalate: If high-risk, isolate host or escalate to IR per policy.
5. Evidence: Save the report row(s), file hash, timestamps, and file path.
6. Document: Summary + decision + next steps.

## Escalation Triggers (examples)
- New/modified scripts or executables in Startup, System32, Program Files, or user AppData
- Unexpected mass file changes in a short window
- Changes tied to a suspicious process chain (Office → PowerShell, etc.)
