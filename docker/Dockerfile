FROM nixos/nix:1.11

RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
RUN nix-channel --update
RUN nix-env -i openvpn
ENTRYPOINT openvpn
