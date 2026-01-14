# TESTING.md
# Testing devenv-py2nix

## Quick Test Setup

1. Create a test devenv project:

```bash
mkdir test-devenv && cd test-devenv
```

2. Create `devenv.yaml`:

```yaml
inputs:
  nixpkgs:
    url: github:NixOS/nixpkgs/nixos-unstable
  devenv-py2nix:
    url: path:../devenv-py2nix  # or your github URL

imports:
  - devenv-py2nix
```

3. Create `devenv.nix`:

```nix
{ config, ... }:

let
  testPkg = config.languages.python.import ../devenv-py2nix/examples/test-project {};
in
{
  languages.python = {
    enable = true;
    version = "3.12";
  };
  
  packages = [ testPkg ];
}
```

4. Run:

```bash
devenv shell
python -c "import requests; import pydantic; print('Success!')"
```

## Expected Results

- Shell activates without errors
- Python has access to `requests` and `pydantic`
- No conflicts with existing devenv Python functionality

## Troubleshooting

**Error: "config.lib.getInput not found"**
- Ensure you're using a recent devenv version
- This function is needed to fetch dependencies

**Error: "languages.python not found"**
- Add `languages.python.enable = true` before using import

**Build failures**
- Check that pyproject.toml is valid
- Verify UV can resolve dependencies normally
- Try: `uv sync` in project directory first
