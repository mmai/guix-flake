{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  # inputs.guix.url = "github:mmai/guix-flake";
  inputs.guix.url = "/home/henri/travaux/nix_flakes/guix-flake";

  outputs = { self, nixpkgs, guix }: 
   {
    nixosConfigurations = {

      container = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          guix.nixosModule
          ( { pkgs, ... }: 
          let hostname = "guix";
          in {
            boot.isContainer = true;

            # Let 'nixos-version --json' know about the Git revision
            # of this flake.
            system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

            # Network configuration.
            networking.useDHCP = true;
            networking.hostName = hostname;

            nixpkgs.overlays = [ guix.overlay ];

            services.guix = {
              enable = true;
            };
          })
        ];
      };

    };
  };
}
