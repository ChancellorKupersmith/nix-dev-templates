{
  inputs = {
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";
    nixos-config.url = "git+ssh://git@github.com/ChancellorKupersmith/NixieOS.git";
    nixpkgs.follows = "nix-ros-overlay/nixpkgs"; # IMPORTANT!!!
    nixpkgs-latest.follows = "nixos-config/nixpkgs";
  };
  outputs =
    {
      self,
      nix-ros-overlay,
      nixpkgs,
      nixpkgs-latest,
      ...
    }:
    nix-ros-overlay.inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs-ros = import nixpkgs {
          inherit system;
          overlays = [ nix-ros-overlay.overlays.default ];
        };
        pkgs = import nixpkgs-latest {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "Example project";
          packages = [
            pkgs-ros.colcon
            pkgs.mujoco
            (pkgs.python3.withPackages (
              ps: with ps; [
                pandas
                numpy
                requests
                mujoco
              ]
            ))

            # ... other non-ROS packages
            (
              with pkgs-ros.rosPackages.humble;
              buildEnv {
                paths = [
                  ros-core
                  # ... other ROS packages
                ];
              }
            )
          ];
        };
      }
    );
  nixConfig = {
    extra-substituters = [
      "https://attic.iid.ciirc.cvut.cz/ros"
      "https://ros.cachix.org"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
    ];
    extra-trusted-public-keys = [
      "ros:JR95vUYsShSqfA1VTYoFt1Nz6uXasm5QrcOsGry9f6Q="
      "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };
}
