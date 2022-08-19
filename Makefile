update:
	nix flake lock --update-input nixpkgs guix
local:
	cd container && nix flake lock --update-input guix && cd -
	sudo nixos-container destroy guix
	sudo nixos-container create guix --flake ./container/
	sudo nixos-container start guix
root:
	sudo nixos-container root-login guix
