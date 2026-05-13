{
  description = "Human-Led Architectural TDD for Aider";

  inputs = {
    nixos-config.url = "git+ssh://git@github.com/ChancellorKupersmith/NixieOS.git";
    nixpkgs.follows = "nixos-config/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixos-config, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        # Pull system-level Ollama config
        ollamaHost = nixos-config.nixosConfigurations.nixie.config.services.ollama.host or "127.0.0.1";
        ollamaPort = nixos-config.nixosConfigurations.nixie.config.services.ollama.port or 11434;
        ollamaUrl  = "http://${ollamaHost}:${toString ollamaPort}";

        coderModel = "qwen3-coder:latest"; 

      in {
        devShells.default = pkgs.mkShell {
          name = "vscodium-aider-tdd";

          packages = with pkgs; [
            just
            aider-chat
            pkgs.mujoco
            (pkgs.python3.withPackages (
              ps: with ps; [
                pandas
                numpy
                requests
                mujoco
                pytest
              ]
            ))
          ];

          OLLAMA_HOST = ollamaUrl;
          AIDER_MODEL = "ollama/${coderModel}";
          
          # This tells Aider to use VSCodium when you use the /editor command
          EDITOR = "codium --wait";

          shellHook = ''
            echo "🚀 VSCodium + Aider TDD Active"
            echo "   1. You write stubs and tests in Codium."
            echo "   2. Run 'just impl' in the integrated terminal."
          '';
        };
      }
    );
}