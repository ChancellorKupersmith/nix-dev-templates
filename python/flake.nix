{
  description = "A Nix-flake-based Python development environment";

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
    in
    {
      devShells = forEachSupportedSystem ({ pkgs, unstable-pkgs }: 
      let 
        pythonPackages = pkgs.python312.withPackages (ps: with ps; [

        ]);
        PythonVSCodeExtensions = with unstable-pkgs.vscode-extensions; [
          ms-python.python
          aaron-bond.better-comments
        ];      
        # ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          # {
          #   name = "remote-ssh-edit";
          #   publisher = "ms-vscode-remote";
          #   version = "0.47.2";
          #   sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
          # }
        # ];
        # Here we merge the parent’s VS Code extensions (if any) with our extra extensions.
        mergedVscodeExtensions =
          (unstable-pkgs.vscode-extensions.vscodeExtensions or [])
          ++ extraPythonExtensions;
      in 
      {
        default = pkgs.mkShell {
          buildInputs = [
            pythonPackages
          ];
          packages = [
            (unstable-pkgs.vscode-with-extensions.override {
                vscode = unstable-pkgs.vscodium;
                # Merge parent's VS Code extensions with our extras.
                vscodeExtensions = mergedVscodeExtensions;
            })
          ] ++ (with pkgs.python312Packages; [ 
            uv
          ]);
        };
      });
    };
}
