# Local mirrors of official UCB DataHub sources (gitignored)

Everything in this folder **except this README** is gitignored (`website/maintainer/mirrors/*` in the repo [`.gitignore`](../../../.gitignore)). These are read-only local copies of official sources so maintainers can grep/read them offline. **Never commit mirror contents.**

| Path | Source | Branch | Purpose |
|------|--------|--------|---------|
| `datahub/` | [berkeley-dsep-infra/datahub](https://github.com/berkeley-dsep-infra/datahub) | `staging` | Hub deployment configs (`deployments/r/config/common.yaml` has memory limits), issue templates (`.github/ISSUE_TEMPLATE/add_memory_config_request.yml`), operator docs |
| `curriculum-guide/` | [berkeley-cdss/curriculum-guide](https://github.com/berkeley-cdss/curriculum-guide) | default | Source of [curriculum-guide.datahub.berkeley.edu](https://curriculum-guide.datahub.berkeley.edu/) — instructor-facing policy incl. `support/memory-cpu.md` (RAM request process + auto-approval thresholds) |
| `espm-288-website/` | [espm-288/website](https://github.com/espm-288/website) | default | Carl Boettiger's ESPM-288 course site (Quarto) — precedent for spatial-course DataHub setup |
| `datahub-ram-issues.json` | `gh issue list` dump | — | All ~60 "Request more RAM" issue threads (bodies + comments) from berkeley-dsep-infra/datahub; evidence base for [`../REQUESTS.md`](../REQUESTS.md) |

First cloned / dumped: **2026-07-07** (shallow, `--depth 1`).

## Refresh

```bash
# from repo root
cd website/maintainer/mirrors
git -C datahub pull --depth 1
git -C curriculum-guide pull --depth 1
git -C espm-288-website pull --depth 1

# re-dump issue threads
gh issue list --repo berkeley-dsep-infra/datahub \
  --search '"Request more RAM"' --state all --limit 60 \
  --json number,title,state,createdAt,closedAt,author,body,comments \
  > datahub-ram-issues.json
```

## Recreate from scratch

```bash
# from repo root
mkdir -p website/maintainer/mirrors
git clone --depth 1 --branch staging https://github.com/berkeley-dsep-infra/datahub.git website/maintainer/mirrors/datahub
git clone --depth 1 https://github.com/berkeley-cdss/curriculum-guide.git website/maintainer/mirrors/curriculum-guide
git clone --depth 1 https://github.com/espm-288/website.git website/maintainer/mirrors/espm-288-website
```

## Key files to grep

- `datahub/deployments/r/config/common.yaml` — r.datahub memory (`guarantee: 512M, limit: 1G`) and per-course `group_profiles` overrides
- `datahub/deployments/stat20/config/common.yaml` — stat20 memory + bCourses allowlist pattern
- `datahub/.github/ISSUE_TEMPLATE/add_memory_config_request.yml` — the RAM request form fields
- `curriculum-guide/support/memory-cpu.md` — request policy, auto-approval math
- `espm-288-website/_quarto.yml`, `espm-288-website/overview/` — Boettiger course structure
