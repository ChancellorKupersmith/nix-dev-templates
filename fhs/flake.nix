{
  description = "A FHS nix shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  outputs = { self, nixpkgs }:
    let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
        fhs = pkgs.buildFHSUserEnv {
            name = "fhs-shell";
            multiPkgs = pkgs: [
    
            ];
            
            profile = ''
                reset # fixes invisible chars bug
            '';
        };
    in
    {
        devShells.${system}.default = fhs.env;
    };
}