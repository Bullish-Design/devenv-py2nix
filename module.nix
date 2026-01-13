# module.nix
{ pkgs
, config
, lib
, ...
}:

let
  cfg = config.languages.python;

  # Fetch uv2nix and related tools via devenv's input mechanism
  uv2nix = config.lib.getInput {
    name = "uv2nix";
    url = "github:pyproject-nix/uv2nix";
    attribute = "languages.python.import";
    follows = [ "nixpkgs" ];
  };

  pyproject-nix = config.lib.getInput {
    name = "pyproject-nix";
    url = "github:pyproject-nix/pyproject.nix";
    attribute = "languages.python.import";
    follows = [ "nixpkgs" ];
  };

  pyproject-build-systems = config.lib.getInput {
    name = "pyproject-build-systems";
    url = "github:pyproject-nix/build-system-pkgs";
    attribute = "languages.python.import";
    follows = [ "nixpkgs" ];
  };

in
{
  options.languages.python = {
    import = lib.mkOption {
      type = lib.types.functionTo (lib.types.functionTo lib.types.package);
      description = ''
        Import a Python project using uv2nix.

        This function takes a path to a directory containing a pyproject.toml file
        and returns a derivation that builds the Python project using uv2nix.

        The project must be UV-compatible with a valid pyproject.toml.

        Example usage:
        ```nix
        let
          mypackage = config.languages.python.import ./path/to/python/project {};
        in {
          languages.python.enable = true;
          packages = [ mypackage ];
        }
        ```

        Optional arguments:
        - packageName: Override the package name (defaults to project.name from pyproject.toml)
      '';
    };
  };

  config = lib.mkIf (cfg.enable or false) {
    languages.python.import = path: args:
      let
        # Load workspace using uv2nix
        workspace = uv2nix.lib.workspace.loadWorkspace { 
          workspaceRoot = path; 
        };

        # Create package overlay from workspace
        overlay = workspace.mkPyprojectOverlay {
          sourcePreference = "wheel";
        };

        # Try to infer package name from pyproject.toml or use directory name as fallback
        packageName = args.packageName or (
          let
            pyprojectToml =
              if builtins.pathExists (path + "/pyproject.toml")
              then builtins.fromTOML (builtins.readFile (path + "/pyproject.toml"))
              else { };
          in
            pyprojectToml.project.name or (builtins.baseNameOf (builtins.toString path))
        );

        # Construct package set using pyproject-nix and apply overlays
        # Uses the transformed cfg.package from devenv's main python module
        pythonSet = (pkgs.callPackage pyproject-nix.build.packages {
          python = cfg.package;
        }).overrideScope (lib.composeManyExtensions [
          pyproject-build-systems.overlays.default
          overlay
        ]);
      in
      pythonSet.mkVirtualEnv "${packageName}-env" workspace.deps.default;
  };
}
