{
  description = "A flake to install a custom-build of spotify-player";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";

    # overlay (inheritance) version
    # pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };

    # composition version
    npkgs = nixpkgs.legacyPackages.${system};
  in {
    # packages.x86_64-linux.splayer = npkgs.spotify-player.override{ withAudioBackend = "pulseaudio"; };
    # packages.x86_64-linux.default = self.packages.x86_64-linux.splayer;


    # overlay (inheritance) version
    # overlays.default = (self: super: {
    #   spotify-player = super.spotify-player.override {  withAudioBackend = "pulseaudio";  };
    # });
    # use this if you want this flake to only contain overridden packages
    # legacyPackages.${system} = {
    #     inherit (pkgs) spotify-player;
    # };
    # use this to have this flake act as a replacement for nixpkgs
    # legacyPackages.${system} = pkgs;

    # composition version
    legacyPackages.${system} = npkgs // {
      spotify-player = npkgs.spotify-player.override{ withAudioBackend = "pulseaudio"; };
    };
  };
}
