{
  description = "A flake that provides nixpkgs outputs with custom packages";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    # using import so i can configure nix
    # pkgs = nixpkgs.legacyPackages.${system};
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    overrides = builtins.mapAttrs (name: value: pkgs.${name}.override value) {
      spotify-player = { withAudioBackend = "pulseaudio"; };
      librespot      = { withPulseAudio   = true        ; };
      siglo          = { python3 = (pkgs.python3.withPackages (python-pkgs: [
        python-pkgs.setuptools
      ]));};
      # TODO: needs work
      # pywal16        = { python3 = (pkgs.python3.withPackages (python-pkgs:
      #     pkgs.pywal16.optional-dependencies.all
      # ));};
    }
    //
    {
      # TODO: figure out what's wrong with pywal >=3.8.9
      pywal16 = (pkgs.pywal16.overridePythonAttrs (old: rec {
        version = "3.8.6";
        src = pkgs.fetchFromGitHub {
          owner = "eylles";
          repo = "pywal16";
          tag = version;
          # TODO: figure out where to get this hash
          hash = "sha256-aq9I9KJnzwFjfLZ2fzW80abJQ/oSX7FcmCXYi1JMY7Q=";
        };
      }));
      # .override {
      #   python3 = (pkgs.python3.withPackages (python-pkgs:
      #     pkgs.pywal16.optional-dependencies.all
      #   ));
      # };
    };
    legacyPackages = nixpkgs.legacyPackages // { ${system} = pkgs // overrides; };


    # TODO: allow for layering of deps
    # using with self.packages.${system}.devShells; [ foo bar ]

    # DEV ENVS
    devShells.${system} = {

      # TODO: use symlinkJoin to create metapackages for easy loading and
      # unloading of sets of packages
      latex = pkgs.mkShell {
        packages = with pkgs; [
          texlive.combined.scheme-full
          texlab
          tectonic
          # TODO: not yet working in isolated enf
          # needs display, xauthority, and xdg_cache_home
          zathura
        ];
        # TODO: not working in zsh
        shellHook = '' export PS1="(nixdev) $PS1" '';
      };

      arm = pkgs.mkShell {
        packages = with pkgs; [
          gcc-arm-embedded
          bear
          codespell
          cppcheck
          doxygen
          gtest
          lcov
          gdb
          stm32flash
        ];
      };

      cpp = pkgs.mkShell.override {
        packages = with pkgs; [
          clang-tools
          cmake
          codespell
          conan
          cppcheck
          doxygen
          gtest
          lcov
          vcpkg
          vcpkg-tool
        ] ++ (if system == "aarch64-darwin" then [ ] else [ gdb ]);
      };

      systemverilog = pkgs.mkShell {
        packages = with pkgs; [
          quartus-prime-lite
          usb-blaster-udev-rules
        ];
        shellHook = ''
          # export PATH=$XDG_STATE_HOME/nix/profile/questa_fse/bin:$PATH
          # export PATH=$XDG_STATE_HOME/nix/profile/quartus/bin:$PATH
          export PS1="(nixdev) $PS1"
        '';
      };

      pinetime = pkgs.mkShell {
        packages = with pkgs; [
          # TODO: basics: find out why these parentheses were needed
          (siglo.override { python3 = python-with-distutils; })
          itd
        ];
      };
    };
  in
  nixpkgs // { inherit legacyPackages; inherit devShells; };
}

# least agro version: a single additional package
# {
#   description = "A flake to install a custom-build of spotify-player";
#   inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
#
#   outputs = { self, nixpkgs }:
#   let
#     system = "x86_64-linux";
#     pkgs = nixpkgs.legacyPackages.${system};
#   in
#   {
#     legacyPackages.${system} =
#       builtins.mapAttrs (name: value: pkgs.${name}.override value) {
#         spotify-player = { withAudioBackend = "pulseaudio"; };
#         librespot      = { withPulseAudio   = true        ; };
#     };
#   };
# }

# medium agro version: expose all of nix through this flake without overlaying
# this version prevents rebuilds when overriding a dependency like gcc and is
# more of a convenient way to use nixpkgs and mask (ideally only) leaf packages
# {
#   description = "A flake to install a custom-build of spotify-player";
#   inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
#
#   outputs = { self, nixpkgs }:
#   let
#     system = "x86_64-linux";
#     # using import so i can configure nix
#     # pkgs = nixpkgs.legacyPackages.${system};
#     pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
#     legacyPackages = nixpkgs.legacyPackages // { ${system} = pkgs //
#       builtins.mapAttrs (name: value: pkgs.${name}.override value) {
#         spotify-player = { withAudioBackend = "pulseaudio"; };
#         librespot      = { withPulseAudio   = true        ; };
#       };
#     };
#   in
#   nixpkgs // { inherit legacyPackages; };
# }

# most agro version: basically recreate nixpkgs
# {
#   description = "A flake to install a custom-build of spotify-player";
#   inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
#
#   outputs = { self, nixpkgs }:
#   let
#     system = "x86_64-linux";
#     pkgs = import nixpkgs {
#       inherit system;
#       overlays = [(self: super:
#         builtins.mapAttrs (name: value: super.${name}.override value) {
#           spotify-player = { withAudioBackend = "pulseaudio"; };
#           librespot      = { withPulseAudio   = true        ; };
#         }
#       )];
#     };
#     legacyPackages = nixpkgs.legacyPackages // { ${system} = pkgs; };
#   in
#   nixpkgs // { inherit legacyPackages; };
# }

# {
#   description = "A flake to install a custom-build of spotify-player";
#   inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
#
#   outputs = { self, nixpkgs }:
#   let
#     system = "x86_64-linux";
#
#     # overlay (inheritance) version
#     # pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
#
#     # composition version
#     npkgs = nixpkgs.legacyPackages.${system};
#   in
#   nixpkgs // # evil version that makes this whole flake equivalent to nixpkgs
#   {
#     # packages.x86_64-linux.splayer = npkgs.spotify-player.override{ withAudioBackend = "pulseaudio"; };
#     # packages.x86_64-linux.default = self.packages.x86_64-linux.splayer;
#
#
#     # overlay (inheritance) version
#     # overlays.default = (self: super: {
#     #   spotify-player = super.spotify-player.override {  withAudioBackend = "pulseaudio";  };
#     # });
#     # use this if you want this flake to only contain overridden packages
#     # legacyPackages.${system} = {
#     #     inherit (pkgs) spotify-player;
#     # };
#     # use this to have this flake act as a replacement for nixpkgs
#     # legacyPackages.${system} = pkgs;
#
#
#     # composition version
#     # legacyPackages.${system} = npkgs // {
#     #   spotify-player = npkgs.spotify-player.override{ withAudioBackend = "pulseaudio"; };
#     #   librespot      = npkgs.librespot     .override{ withPulseAudio   = true        ; };
#     # };
#
#     # evil version that makes this whole flake equivalent to nixpkgs
#     # hmm this and overlays feels like inheritance
#     legacyPackages.${system} = npkgs // {
#       spotify-player = npkgs.spotify-player.override{ withAudioBackend = "pulseaudio"; };
#       librespot      = npkgs.librespot     .override{ withPulseAudio   = true        ; };
#     };
#   };
# }

# some example commands
# nix flake metadata 'github:NixOS/nixpkgs/nixpkgs-unstable'
# nix flake metadata 'flake:nixpkgs'
# nix flake update --flake 'github:NixOS/nixpkgs/nixpkgs-unstable'
# nix flake update --flake 'flake:nixpkgs'
# nix flake update --flake nixpkgs
# nix flake update $(pwd)
