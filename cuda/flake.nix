{
    description = "A Nix-flake-based Cuda development environment";
    # NIXOS CUDA docs
    # https://nixos.wiki/wiki/CUDA
    # https://github.com/NixOS/nixpkgs/blob/56dde4feef76965f14d8dc70e9e2fd21984d4880/doc/languages-frameworks/cuda.section.md
    # https://github.com/NixOS/nixpkgs/tree/56dde4feef76965f14d8dc70e9e2fd21984d4880/pkgs/development/cuda-modules
    inputs = {
        nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";
        nixpkgs-unstable.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.0.tar.gz";
    };

    outputs = { self, nixpkgs, nixpkgs-unstable }:
    let
        supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
        forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
            pkgs = import nixpkgs { inherit system; };
            unstable-pkgs = import nixpkgs-unstable { 
                inherit system;
                config.allowUnfree = true;
            };
        });
    in {
        devShells = forEachSupportedSystem ({ pkgs, unstable-pkgs }: {
            default = pkgs.mkShell {
                nativeBuildInputs = [ pkgs.pkg-config ];
                buildInputs = [
                    unstable-pkgs.cudatoolkit
                    unstable-pkgs.linuxPackages.nvidia_x11
                ];
                packages = [];
                shellHook = ''
                    export CUDA_PATH=${unstable-pkgs.cudatoolkit}
                    export LD_LIBRARY_PATH=:$LD_LIBRARY_PATH:${unstable-pkgs.linuxPackages.nvidia_x11}/lib
                    export EXTRA_LDFLAGS="-L/lib -L${unstable-pkgs.linuxPackages.nvidia_x11}/lib"
                    export EXTRA_CCFLAGS="-I/usr/include"
                '';
            };
        });
    };
}
