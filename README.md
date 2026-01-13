# devenv-python-uv2nix/README.md
# devenv Python uv2nix Module

External devenv module that adds `languages.python.import` functionality using uv2nix.

## Features

- Import Python projects with `pyproject.toml` managed by UV
- Builds virtual environments with project dependencies using uv2nix
- Works with devenv's existing Python language support
- Uses the transformed/patched Python package from devenv

## Requirements

- devenv with `languages.python.enable = true`
- UV-compatible Python project with `pyproject.toml`

## Installation

Add to your `devenv.yaml`:

```yaml
inputs:
  python-uv2nix:
    url: github:yourusername/devenv-python-uv2nix

imports:
  - python-uv2nix
```

Or in your flake-based devenv:

```nix
{
  inputs = {
    devenv.url = "github:cachix/devenv";
    python-uv2nix.url = "github:yourusername/devenv-python-uv2nix";
  };

  outputs = { self, nixpkgs, devenv, python-uv2nix, ... }:
    devenv.lib.mkShell {
      inherit inputs pkgs;
      modules = [
        python-uv2nix.devenvModules.default
        ({ config, ... }: {
          # your config here
        })
      ];
    };
}
```

## Usage

```nix
{ config, ... }:

let
  myproject = config.languages.python.import ./my-python-project {};
in
{
  languages.python.enable = true;
  packages = [ myproject ];
}
```

### With Custom Package Name

```nix
{ config, ... }:

let
  myproject = config.languages.python.import ./my-python-project {
    packageName = "custom-name";
  };
in
{
  languages.python.enable = true;
  packages = [ myproject ];
}
```

## How It Works

1. Uses `uv2nix.lib.workspace.loadWorkspace` to parse your `pyproject.toml`
2. Creates a pyproject overlay from the workspace
3. Builds a Python package set using `pyproject-nix` with devenv's Python
4. Returns a virtual environment with your project's dependencies

## Limitations

- UV-only (no Poetry or pip requirements.txt support)
- Requires valid `pyproject.toml` in project root
- MVP implementation - advanced features may be missing

## Development

This module is minimal by design. It adds one function: `languages.python.import`.

Does not interfere with:
- `languages.python.uv.*` settings
- `languages.python.venv.*` settings
- `languages.python.poetry.*` settings
- Any other existing devenv Python functionality
