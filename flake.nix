{
  description = "Gas Town - Multi Agent Orchestrator";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";

    gastown = {
      url = "github:steveyegge/gastown";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    beads = {
      url = "github:steveyegge/beads";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gastown-gui = {
      url = "github:ropwareJB/gastown-gui";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      packages.${system} =
        let
          bds = import ./nix/pkg/beads.nix {
            flake = self;
            inherit pkgs system;
          };
        in {
          gt = import ./nix/pkg/gastown.nix {
            flake = self;
            inherit pkgs system;
          };
          beads = bds.beads;
          beadsBashCompletions = bds.beadsBashCompletions;
        };

      nixosModules = {
        deployment = import ./nix/gastown.nix {
          flake = self;
          system = system;
        };

        default = { pkgs, ... }: {
          environment.systemPackages = if builtins.hasAttr pkgs.system self.packages
            then [ self.packages.${pkgs.system}.default ]
            else [ ];
        };
      };

    };
}
