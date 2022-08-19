{
  description = "Guix";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;

  outputs = { self, nixpkgs }:
  let
    version = "1.3.0";
    systems = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system); 
    # Memoize nixpkgs for different platforms for efficiency.
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      }
    );
  in {
    overlay = final: prev: {

      guix = with final; (stdenv.mkDerivation {
          pname = "guix";
          inherit version;

          src = fetchurl {
            url = "https://ftp.gnu.org/gnu/guix/guix-binary-${version}.${stdenv.targetPlatform.system}.tar.xz";
            sha256 = {
              "x86_64-linux" = "sha256-xffvtIlHVF5J0tr0jQ+DLzXSqNGfZdqvYHlCWsMnwFA=";
              # "i686-linux" = "10qkz12nsw0cm673jqx0q6ls4m2bsig022iqr0rblpfrgzx20f0i";
              # "aarch64-linux" = "0vzlpvdkiwz4w08xvwlqdhz35mjfmf1v3q8mv7fy09bk0y3cwzqs";
            }."${stdenv.targetPlatform.system}";
          };
          sourceRoot = ".";

          outputs = [ "out" "store" "var" ];
          phases = [ "unpackPhase" "installPhase" ];

          installPhase = ''
            # copy the /gnu/store content
            mkdir -p $store
            cp -r gnu $store

            # copy /var content
            mkdir -p $var
            cp -r var $var

            # link guix binaries
            mkdir -p $out/bin
            ln -s /var/guix/profiles/per-user/root/current-guix/bin/guix $out/bin/guix
            ln -s /var/guix/profiles/per-user/root/current-guix/bin/guix-daemon $out/bin/guix-daemon
          '';

          meta = with lib; {
            description = "The GNU Guix package manager";
            homepage = https://www.gnu.org/software/guix/;
            license = licenses.gpl3Plus;
            platforms = platforms.linux;
            maintainers = with maintainers; [ mmai ];
          };
      });
    };


    packages = forAllSystems (system: {
      inherit (nixpkgsFor.${system}) guix;
    });

    defaultPackage = forAllSystems (system: self.packages.${system}.guix);


    # guix service module
    nixosModule = (import ./module.nix);

  };
}
