# Python environment manifests — nerv, 12 Aug 2026

A point-in-time record of nerv's Python environments, captured **before** the
migration to mise. Not config: chezmoi never applies this directory (see the
`python-manifests` entries in `.chezmoiignore`).

Why it exists: only 3 of nerv's 8 pyenv virtualenvs mapped to a project
directory, and only `llm-services` had a dependency file (`pyproject.toml` +
`poetry.lock`). Without these manifests, deleting pyenv would have destroyed the
only record of what the other envs contained.

## pyenv virtualenvs (Python 3.11.9, under `3.11.9/envs/`)

| Env | Packages | Project dir | Dependency file |
|---|---:|---|---|
| `gpts` | 209 | — | — |
| `librarian` | 154 | — | — |
| `pai-llm-services` | 137 | — | — |
| `aider` | 122 | `~/dev/work/aider-env` | none |
| `cli` | 77 | — | — |
| `grpc` | 74 | — | — |
| `llm-services` | 52 | `~/dev/work/pai/llm-services` | `pyproject.toml` + `poetry.lock` |
| `mcp-atlassian` | 0 | `~/dev/work/tools/mcp-atlassian` | none |

`mcp-atlassian` was empty — no manifest written.

## conda envs (miniconda3-3.11-24.1.2-0)

Captured twice: `.pip.txt` (`pip freeze`) and `.conda.txt`
(`conda list --export`), because conda-installed packages are not all visible
to pip.

| Env | pip | conda | Python |
|---|---:|---:|---|
| `prop-ai` | 306 | 338 | 3.11.8 |
| `gpt-sciteline` | 218 | 262 | 3.11.9 |
| `gpt-services` | 76 | 122 | 3.11.9 |
| `test_env` | 76 | 122 | 3.11.8 |

**Dead envs, no manifest written** — these had no Python binary and their
`conda list --export` contained only header comments:
`graphrag_personal`, `graphrag_test`, `prop-ai-agents`.

## Recreating an env as a plain venv

mise manages interpreters but not pyenv-virtualenv, so the named envs become
ordinary venvs:

```sh
mise use -g python@3.11
python -m venv ~/.venvs/<name>
source ~/.venvs/<name>/bin/activate
pip install -r python-manifests/pyenv-<name>.txt
```

For conda envs use `.conda.txt`, **not** `.pip.txt`:

```sh
conda create --name <env> --file python-manifests/conda-<env>.conda.txt
```

`pip freeze` inside a conda env reports conda-installed packages as
`name @ file:///home/conda/feedstock_root/...` — build paths from conda-forge's
CI runners that do not exist on any local machine, so `pip install -r` on a
`.pip.txt` fails partway through. The `.pip.txt` files are kept only as a record
of version numbers.

conda itself is staying — these four are recorded for reference, not migration.
