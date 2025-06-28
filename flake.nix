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
{
  description = "A flake to install a custom-build of spotify-player";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    legacyPackages = nixpkgs.legacyPackages // { ${system} = pkgs //
      builtins.mapAttrs (name: value: pkgs.${name}.override value) {
        spotify-player = { withAudioBackend = "pulseaudio"; };
        librespot      = { withPulseAudio   = true        ; };
      };
    };
  in
  nixpkgs // { inherit legacyPackages; };
}
