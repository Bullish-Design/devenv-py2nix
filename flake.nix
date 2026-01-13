# flake.nix
{
  description = "devenv module for uv2nix Python project imports";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    {
      devenvModules.default = ./module.nix;
      devenvModules.devenv-py2nix = ./module.nix;
    };
}
