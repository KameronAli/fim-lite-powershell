# FIM-Lite (PowerShell) — File Integrity Monitoring Script

Lightweight **File Integrity Monitoring (FIM)** automation script written in **Windows PowerShell 5.1**.

It creates a **known-good baseline** of file integrity (SHA-256 + metadata) for a target directory, then compares later runs to detect:

- **Created** files
- **Modified** files (hash drift)
- **Deleted** files

---

## Why this matters (SOC use case)

File integrity monitoring helps with:
- Detecting **unauthorized or unexpected changes**
- Supporting **incident response** investigations (what changed, when, where)
- Creating an **audit trail** that can be reviewed quickly or ingested into a SIEM later

---

## How it works (high level)

### Baseline mode
- Recursively scans a target path
- Collects per-file:
  - Full path
  - SHA-256 hash
  - Size
  - Last write time (UTC)
- Saves results to **`baseline.csv`**

### Compare mode
- Re-scans the same target path
- Compares current snapshot to `baseline.csv`
- Outputs change events to **`fim_report.csv`** with:
  - Type (Created/Modified/Deleted)
  - Path
  - Old hash / New hash
  - Timestamp (UTC)

---


## Demo

Example output after creating `new.txt` and running Compare:

![FIM demo output](images/test%20results.png)




## Requirements

- **Windows PowerShell 5.1**
- Permission to read the target directory

> If scripts are blocked, set execution policy (CurrentUser):
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
