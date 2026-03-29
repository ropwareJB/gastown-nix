{ flake, system, domain ? null, ...}: { config, pkgs, lib, ...}:
let
  serviceUser = "gastown";
  serviceGroup = "gastown";
  gt = flake.packages.${system}.gt;
  beads = flake.packages.${system}.beads;
  beadsBashCompletions = flake.packages.${system}.beadsBashCompletions;
in
{
  imports = [
    flake.inputs.gastown-gui.nixosModules.deployment
    (flake.inputs.home-manager.nixosModules.home-manager)
  ];

  services.gastown-gui = {
    enable = true;
    host = "127.0.0.1";
    port = 8080;
    user = serviceUser;
    group = serviceGroup;
    gtPackage = gt;
    beadsPackage = beads;
    gtRoot = "/home/${serviceUser}/gt";
    environment = {
      CORS_ORIGINS = builtins.concatStringsSep ";" (
        [
          "http://localhost:${toString config.services.gastown-gui.port}"
          "http://127.0.0.1:${toString config.services.gastown-gui.port}"
        ] ++ (if domain != null then [ "https://${domain}" ] else [ ])
      );
    };
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    wget
    google-chrome
    brave
    xvfb-run # Virtual Display for headless chrome
    tmux
    claude-code
    codex
    opencode
    glab
    icu   # dependency for dolt
    dolt
    xdg-utils
    gt
    beads
    beadsBashCompletions
  ];

  users.groups.${serviceGroup} = {};
  users.users.${serviceUser} = {
    isNormalUser = true;
    isSystemUser = lib.mkForce false;
    group = serviceGroup;
    home = lib.mkForce "/home/gastown";
    createHome = true;
    extraGroups = [];
  };

  networking.firewall = {
    allowedTCPPorts = [ config.services.gastown-gui.port ];
  };
}
