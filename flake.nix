{
  description = "lipsum";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    zig.url = "git+https://git.sr.ht/~dbuckley/zig-flake";
  };

  outputs = { self, nixpkgs, zig, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ zig.overlay.${system} ];
        };
      in rec {
        devShell = pkgs.mkShell {
          name = "lipsum";
          nativeBuildInputs = with pkgs; [
            zig_master
            zls
            gyro
          ];
        };
      });
}
