{
  description = "FHS Nix Shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs }:
    let
        supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
        forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
            pkgs = import nixpkgs { inherit system; };
        });
    in
    {
        # Create an FHS user environment
        fhsShells = forEachSupportedSystem ({ pkgs }: {
            default = pkgs.fhsUserEnv {
                name = "fhs-env";
                buildInputs = with pkgs [
                    # Add any other packages you need
                    cudatoolkit
                ];

                # Optionally, specify any additional configuration
                # e.g., setting up environment variables
                shellHook = ''
                    export CUDA_PATH=${pkgs.cudatoolkit}/bin
                    export PATH=$PATH:${pkgs.cudatoolkit}/bin
                    # Add other environment variables or setup commands here
                '';
            };
        });
    };
}
