# Maintainer batch patches

Unified diffs used only by [`../run_all_labs.R`](../run_all_labs.R). They temporarily comment out in-class exercise code that would break non-interactive smoke tests:

| Patch | Lab | What it comments |
|-------|-----|------------------|
| `lab1-batch.patch` | 1 | `__` blanks and open-ended `get_acs(state = "__")` |
| `lab3-batch.patch` | 3 | Intentional `summarize(..., renters = co_totrent)` error demo |

Applied with `patch -p1 --batch` from the repo root before sourcing labs; reversed with `patch -R` on exit (inside `run_batch_labs()`). Reject files: `website/maintainer/patches/*.rej` (not in `code/`).

If a prior run left lab files patched, the next run calls `patch -R` on all maintainer patches first (best-effort).

**Students never see these files in class** — lab scripts stay clean. If a lab edit breaks a patch, regenerate:

```bash
# from repo root — edit /tmp copies, then:
diff -u code/lab1_intro_to_.R /tmp/lab1_patched.R | sed '1,2s|/tmp/|code/|' > website/maintainer/patches/lab1-batch.patch
patch --dry-run -p1 < website/maintainer/patches/lab1-batch.patch
```
