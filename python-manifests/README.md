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
ordinary venvs under `~/.venvs/`:

```sh
"$(mise which python)" -m venv ~/.venvs/<name>
~/.venvs/<name>/bin/python -m pip install --upgrade pip
~/.venvs/<name>/bin/python -m pip install -r python-manifests/pyenv-<name>.txt
source ~/.venvs/<name>/bin/activate
```

**Validated** on `llm-services` (12 Aug 2026): recreated against mise's Python
3.11.15 from a manifest captured on 3.11.9, and `pip freeze` came back
byte-identical to the manifest — every pin resolved. Poetry 1.8.5, black and
coverage all ran, and `poetry check` in the real project returned "All set!".
Roughly 100 MB on disk. The remaining six are left to recreate on demand; the
heavy ones (`gpts`, `librarian`, `pai-llm-services` — numpy, scipy, pandas,
pyarrow, grpcio) will be considerably larger.

Note `llm-services` is Poetry's *tooling* env — poetry, black, coverage, keyring
— not an application runtime. Poetry manages the app's own dependencies from
`pyproject.toml` separately.

### Why pyenv is still installed

Two projects rely on pyenv-virtualenv **auto-activation**, which mise has no
equivalent for — their `.python-version` files name an env rather than a version:

| Project | `.python-version` contains |
|---|---|
| `~/dev/work/pai/llm-services` | `llm-services` (a pyenv virtualenv) |
| `~/dev/work/sciteline/gpt-services` | `miniconda3-3.11-24.1.2-0/envs/gpt-sciteline` (a **conda** env) |

That is also why `python` is absent from `idiomatic_version_file_enable_tools` in
`dot_config/mise/config.toml.tmpl`: mise would try to parse those as versions.

Removing pyenv needs a per-project change, not a dotfiles change — either a
`mise.toml` using `[env] _.python.venv`, or a direnv `.envrc` (direnv is already
installed and configured on both machines). Both mean editing a work repo, so
it is a deliberate decision rather than part of this migration. The second
project points into conda, which is out of scope regardless.

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
