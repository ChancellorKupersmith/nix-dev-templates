{
  description = "Ready-made templates for easily creating flake-driven environments";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      overlays = [
        (final: prev:
          let
            getSystem = "SYSTEM=$(nix eval --impure --raw --expr 'builtins.currentSystem')";
            forEachDir = exec: ''
              for dir in */; do
                (
                  cd "''${dir}"

                  ${exec}
                )
              done
            '';
          in
          {
            format = final.writeShellApplication {
              name = "format";
              runtimeInputs = with final; [ nixpkgs-fmt ];
              text = "nixpkgs-fmt '**/*.nix'";
            };

            # only run this locally, as Actions will run out of disk space
            build = final.writeShellApplication {
              name = "build";
              text = ''
                ${getSystem}

                ${forEachDir ''
                  echo "building ''${dir}"
                  nix build ".#devShells.''${SYSTEM}.default"
                ''}
              '';
            };

            check = final.writeShellApplication {
              name = "check";
              text = forEachDir ''
                echo "checking ''${dir}"
                nix flake check --all-systems --no-build
              '';
            };

            dvt = final.writeShellApplication {
              name = "dvt";
              text = ''
                if [ -z $1 ]; then
                  echo "no template specified"
                  exit 1
                fi

                TEMPLATE=$1

                nix \
                  --experimental-features 'nix-command flakes' \
                  flake init \
                  --template \
                  "github:the-nix-way/dev-templates#''${TEMPLATE}"
              '';
            };

            update = final.writeShellApplication {
              name = "update";
              text = forEachDir ''
                echo "updating ''${dir}"
                nix flake update
              '';
            };
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
          packages = with pkgs; [ build check format update ];
        };
      });

      packages = forEachSupportedSystem ({ pkgs }: rec {
        default = dvt;
        inherit (pkgs) dvt;
      });
    }

    //

    {
      templates = rec {
        clojure = {
          path = ./clojure;
          description = "Clojure development environment";
        };

        csharp = {
          path = ./csharp;
          description = "C# development environment";
        };

        cuda = {
          path = ./cuda;
          description = "CUDA development environment";
        };

        cue = {
          path = ./cue;
          description = "Cue development environment";
        };

        dhall = {
          path = ./dhall;
          description = "Dhall development environment";
        };

        elixir = {
          path = ./elixir;
          description = "Elixir development environment";
        };

        elm = {
          path = ./elm;
          description = "Elm development environment";
        };

        empty = {
          path = ./empty;
          description = "Empty dev template that you can customize at will";
        };

        gleam = {
          path = ./gleam;
          description = "Gleam development environment";
        };

        go = {
          path = ./go;
          description = "Go (Golang) development environment";
        };

        go_js = {
          path = ./go_js;
          description = "Go (Golang) backend, JS frontend development environment";
        };

        hashi = {
          path = ./hashi;
          description = "HashiCorp DevOps tools development environment";
        };

        haskell = {
          path = ./haskell;
          description = "Haskell development environment";
        };

        java = {
          path = ./java;
          description = "Java development environment";
        };

        kotlin = {
          path = ./kotlin;
          description = "Kotlin development environment";
        };

        latex = {
          path = ./latex;
          description = "LaTeX development environment";
        };

        nickel = {
          path = ./nickel;
          description = "Nickel development environment";
        };

        nim = {
          path = ./nim;
          description = "Nim development environment";
        };

        nix = {
          path = ./nix;
          description = "Nix development environment";
        };

        node = {
          path = ./node;
          description = "Node.js development environment";
        };

        opa = {
          path = ./opa;
          description = "Open Policy Agent development environment";
        };

        php = {
          path = ./php;
          description = "PHP development environment";
        };

        protobuf = {
          path = ./protobuf;
          description = "Protobuf development environment";
        };

        pulumi = {
          path = ./pulumi;
          description = "Pulumi development environment";
        };

        purescript = {
          path = ./purescript;
          description = "Purescript development environment";
        };

        python = {
          path = ./python;
          description = "Python development environment";
        };

        ruby = {
          path = ./ruby;
          description = "Ruby development environment";
        };

        rust = {
          path = ./rust;
          description = "Rust development environment";
        };

        rust-toolchain = {
          path = ./rust-toolchain;
          description = "Rust development environment with Rust version defined by a rust-toolchain.toml file";
        };

        scala = {
          path = ./scala;
          description = "Scala development environment";
        };

        shell = {
          path = ./shell;
          description = "Shell script development environment";
        };

        vlang = {
          path = ./vlang;
          description = "Vlang developent environment";
        };

        zig = {
          path = ./zig;
          description = "Zig development environment";
        };

        # Aliases
        rt = rust-toolchain;
      };
    };
}
