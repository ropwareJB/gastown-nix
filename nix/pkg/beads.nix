{ flake, pkgs, ...}:
let
  beadsSrc = flake.inputs.beads;
  beadsBase = pkgs.callPackage (beadsSrc + "/default.nix") {
    inherit pkgs;
    self = beadsSrc;
    buildGoModule = pkgs.buildGo126Module;
  };
  beadsBaseFixed = beadsBase.overrideAttrs (_old: {
    nativeBuildInputs = (_old.nativeBuildInputs or []) ++ [ pkgs.pkg-config ];
    buildInputs = (_old.buildInputs or []) ++ [ pkgs.icu ];
    vendorHash = "sha256-GYPfvsI8eNJbdzrbO7YnMkN2Yt6KZNB7w/2SJD2WdFY=";
  });
  beads = pkgs.stdenv.mkDerivation {
    pname = "beads";
    version = beadsBaseFixed.version;
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      cp ${beadsBaseFixed}/bin/bd $out/bin/bd
      ln -s bd $out/bin/beads

      mkdir -p $out/share/fish/vendor_completions.d
      mkdir -p $out/share/bash-completion/completions
      mkdir -p $out/share/zsh/site-functions

      $out/bin/bd completion fish > $out/share/fish/vendor_completions.d/bd.fish
      $out/bin/bd completion bash > $out/share/bash-completion/completions/bd
      $out/bin/bd completion zsh > $out/share/zsh/site-functions/_bd
    '';
    meta = beadsBaseFixed.meta;
  };
  beadsBashCompletions = pkgs.runCommand "bd-bash-completions" { } ''
    mkdir -p $out/share/bash-completion/completions
    ln -s ${beads}/share/bash-completion/completions/bd $out/share/bash-completion/completions/bd
  '';
in
{ inherit beads beadsBashCompletions; }
