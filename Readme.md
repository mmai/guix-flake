# Guix flake

Guix 1.3.0 for NixOS 22.05 

This is basically a flake adaptation of [@pukkamustard](https://github.com/pukkamustard)'s [pull request for nixkpkgs](https://github.com/NixOS/nixpkgs/pull/56430)

Below is an example of a nixos configuration using this flake.

A reboot may be necessary for the `guix` command to be available.

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  inputs.guix.url = "github:mmai/guix-flake";

  outputs = { self, nixpkgs, guix }: 
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations = {

      myhostname = nixpkgs.lib.nixosSystem {
        system = system;
        modules = [ 
          nixpkgs.nixosModules.notDetected
	        guix.nixosModule
          ( { config, pkgs, ... }:
            { imports = [ ./hardware-configuration.nix ];

              nix = {
                package = pkgs.nixUnstable;
                extraOptions = ''
                  experimental-features = nix-command flakes
                '';
              };

              nixpkgs.overlays = [ guix.overlay ];
              services.guix.enable = true;
            })
        ];
      };

    };
  };
}
```

## Test on a local container

- start the guix container on the local machine : `make local`
- ssh to the vm : `make root`
