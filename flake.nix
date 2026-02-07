{
  description = "Hypr stack aggregator";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

    hyprwayland-scanner = {
      url = "github:hyprwm/hyprwayland-scanner";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    hyprgraphics = {
      url = "github:hyprwm/hyprgraphics";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.hyprutils.follows = "hyprutils";
    };
    aquamarine = {
      url = "github:hyprwm/aquamarine";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.hyprutils.follows = "hyprutils";
      inputs.hyprwayland-scanner.follows = "hyprwayland-scanner";
    };
    hyprwire = {
      url = "github:hyprwm/hyprwire";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.hyprutils.follows = "hyprutils";
    };
    hyprutils = {
      url = "github:hyprwm/hyprutils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    hyprlang = {
      url = "github:hyprwm/hyprlang";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.hyprutils.follows = "hyprutils";
    };
    hyprtoolkit = {
      url = "github:hyprwm/hyprtoolkit";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        hyprutils.follows = "hyprutils";
        hyprlang.follows = "hyprlang";
        aquamarine.follows = "aquamarine";
        hyprgraphics.follows = "hyprgraphics";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
      };
    };

    hyprland = {
      url = "https://github.com/hyprwm/Hyprland.git";
      inputs = {
        pre-commit-hooks.follows = "";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
        hyprgraphics.follows = "hyprgraphics";
        aquamarine.follows = "aquamarine";
        hyprutils.follows = "hyprutils";
        hyprlang.follows = "hyprlang";
        hyprland-guiutils.inputs.hyprtoolkit.follows = "hyprtoolkit";
        hyprwire.follows = "hyprwire";
      };
      type = "git";
      submodules = true;
    };
    hyprlauncher = {
      url = "github:hyprwm/hyprlauncher";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        hyprwayland-scanner.follows = "hyprwayland-scanner";
        hyprgraphics.follows = "hyprgraphics";
        aquamarine.follows = "aquamarine";
        hyprwire.follows = "hyprwire";
        hyprutils.follows = "hyprutils";
        hyprlang.follows = "hyprlang";
        hyprtoolkit.follows = "hyprtoolkit";
      };
    };
  };

  outputs = _inputs @ {
    self,
    nixpkgs,
    systems,
    hyprland,
    hyprlauncher,
    ...
  }: let
    eachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    packages = eachSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      hyprland.packages.${system}
      // hyprlauncher.packages.${system}
      // {
        hyprland = hyprland.packages.${system}.hyprland.overrideAttrs (_oldAttrs: {
          # disko does not work with the src they've set
          src = pkgs.fetchgit {
            url = "https://github.com/hyprwm/Hyprland";
            rev = "f68ac7ef7589e1536d438f7fbfb3ad987538fe0f";
            sha256 = "sha256-R5DYoAbTqze9H1KsgayDv5uDyQKP39MZu/2Nzvq/m+Y=";
          };
        });
      });
  };
}
