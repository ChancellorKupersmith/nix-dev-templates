{
  description = "Flutter mobile development shell";

  inputs = {
    nixos-config.url = "git+ssh://git@github.com/ChancellorKupersmith/NixieOS.git";
    nixpkgs.follows = "nixos-config/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

        flutter = pkgs.flutter;
        jdk = pkgs.jdk17;

        androidSdkPath = "$HOME/Android/Sdk";

        # Runtime libraries required by the Android emulator (hardware-accelerated)
        emulatorRuntimeLibs = with pkgs; [
          libGL
          libpulseaudio
          xorg.libX11
          xorg.libXcomposite
          xorg.libXcursor
          xorg.libXdamage
          xorg.libXext
          xorg.libXfixes
          xorg.libXi
          xorg.libXrandr
          xorg.libXrender
          xorg.libXtst
          xorg.libxcb
          libxkbcommon
          libdrm
          udev
        ];

        # Optional: keep these if you also build Linux desktop apps
        linuxDesktopLibs = with pkgs; [
          gtk3
          glib
          pango
          cairo
          harfbuzz
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          name = "flutter-dev-shell";

          packages = with pkgs; [
            flutter
            jdk

            # native build tools
            cmake
            ninja
            pkg-config
            git
            curl
            unzip
            zip

            # graphics (vulkan/mesa for GPU rendering in emulator)
            vulkan-loader
            mesa
          ]
          ++ emulatorRuntimeLibs    # essential for the emulator
          ++ linuxDesktopLibs;      # only if you do Flutter Linux desktop

          # Note: android-tools NOT included – we use the SDK's own adb.

          shellHook = ''
            export ANDROID_HOME=${androidSdkPath}
            export ANDROID_SDK_ROOT=${androidSdkPath}

            export JAVA_HOME=${jdk.home}

            # Prepend SDK binary directories – these include adb, fastboot, sdkmanager
            export PATH="$ANDROID_HOME/platform-tools:$PATH"
            export PATH="$ANDROID_HOME/emulator:$PATH"
            export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

            export QT_QPA_PLATFORM=xcb

            export PUB_CACHE="$PWD/.pub-cache"
            export GRADLE_USER_HOME="$PWD/.gradle"

            # Let Gradle handle aapt2 – remove the hardcoded override unless absolutely needed.
            # If you still need it, consider using a wildcard:
            # export GRADLE_OPTS="-Dorg.gradle.project.android.aapt2FromMavenOverride=$ANDROID_HOME/build-tools/*/aapt2"

            echo ""
            echo "Flutter Dev Shell"
            echo "-----------------"

            if [ ! -d "$ANDROID_HOME" ]; then
              echo "⚠️  Android SDK not found:"
              echo "   $ANDROID_HOME"
              echo "   Install it via Android Studio or sdkmanager."
              echo "   The shell will work, but Android targets will fail."
            else
              if [ ! -f "$ANDROID_HOME/platform-tools/adb" ]; then
                echo "⚠️  platform-tools missing – install it via SDK Manager."
              fi

              echo "Android SDK : $ANDROID_HOME"
            fi

            # echo "Flutter     : $(flutter --version | head -n 1)"
            echo "Java        : $(java -version 2>&1 | head -n 1)"
            echo ""

            # Check for KVM (hardware acceleration)
            if ! test -e /dev/kvm; then
              echo "⚠️  /dev/kvm not found – the emulator will be slow."
              echo "   Enable KVM in BIOS and add yourself to the 'kvm' group."
            elif ! test -r /dev/kvm || ! test -w /dev/kvm; then
              echo "⚠️  No permission to /dev/kvm – the emulator will fail."
              echo "   Add your user to the 'kvm' group and re-login."
            fi
          '';
        };
      }
    );
}
