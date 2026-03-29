# gastown-nix

Nix flake for packaging and deploying the Gastown stack on NixOS.

This repository provides:

- A patched `gt` package (from `steveyegge/gastown`)
- A packaged `beads` CLI with shell completions (from `steveyegge/beads`)
- A NixOS deployment module that wires `gastown-gui` and related system configuration

## What the flake exports

- `packages.x86_64-linux.gt`
- `packages.x86_64-linux.beads`
- `packages.x86_64-linux.beadsBashCompletions`
- `nixosModules.deployment`
- `nixosModules.default`

Note: outputs are currently targeted at `x86_64-linux`.

## Prerequisites

- Nix with flakes enabled
- Linux/NixOS (`x86_64-linux`)

## Basic usage

From this repository:

```bash
nix flake show
nix build .#gt
nix build .#beads
```

You can also enter a shell with the packaged tools:

```bash
nix shell .#gt .#beads
```

## Use as a flake input (NixOS)

In your system flake:

```nix
{
  inputs.gastown-nix.url = "github:<you-or-org>/gastown-nix";

  outputs = { self, nixpkgs, gastown-nix, ... }: {
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        gastown-nix.nixosModules.deployment
      ];
    };
  };
}
```

The deployment module configures:

- `services.gastown-gui` on `127.0.0.1:8080`
- A `gastown` user/group
- `CORS_ORIGINS` for localhost/loopback (and optional domain when provided)
- Firewall rules for the Gastown GUI port
- Useful system packages (`gt`, `beads`, browser tooling, CLI utilities)

## Optional: provide a domain in CORS origins

`nix/gastown.nix` accepts a `domain` argument. To include `https://<domain>` in `CORS_ORIGINS`, import the module manually with `domain` set:

```nix
{
  modules = [
    (import "${gastown-nix}/nix/gastown.nix" {
      flake = gastown-nix;
      system = "x86_64-linux";
      domain = "gastown.example.com";
    })
  ];
}
```

If `domain = null` (default), only localhost and `127.0.0.1` origins are included.
