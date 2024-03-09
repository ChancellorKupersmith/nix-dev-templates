{
  description = "A Go/JS webstack";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  outputs = { self, nixpkgs }:
      let
        goVersion = 20; # Change this to update the whole stack
        overlays = [
          (final: prev: { go = prev."go_1_${toString goVersion}"; })
          (final: prev: rec {
            nodejs = prev.nodejs_latest;
            pnpm = prev.nodePackages.pnpm;
            yarn = (prev.yarn.override { inherit nodejs; });
          })
        ];
        supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
        forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
          pkgs = import nixpkgs { inherit overlays system; };
        });
      in
      {
        devShells = forEachSupportedSystem ({ pkgs }: {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # go 1.20 (specified by overlay)
              go
              # goimports, godoc, etc.
              gotools
              # https://github.com/golangci/golangci-lint
              golangci-lint

              # JS dependencies
              node2nix nodejs pnpm yarn
            ];
            shellHook = ''
            chmod +x ./init_client_app.sh
            ./init_client_app.sh
            chmod +x ./init_server.sh
            ./init_server.sh
            '';
          };
        });
      };
}
