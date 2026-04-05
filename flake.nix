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
    overlays.default = final: prev: {
      inherit (self.packages.${prev.stdenv.hostPlatform.system}) xdg-desktop-portal-hyprland hyprlauncher hyprland;
    };

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
            rev = "3a7bd8fea2ca9711da5523dc185c05ea30ec0f35";
            sha256 = "sha256-jPG5BSEsW1aRg8aaU8IlySEVO9Ed3jeUuo5k1n1sQpQ=";
          };
        });
      });
  };
}
