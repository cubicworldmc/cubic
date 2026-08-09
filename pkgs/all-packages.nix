{ pkgs }:
let
  jre = pkgs.jdk25;
  gradle = pkgs.gradle_9;
in
{
  plugins = {
    cwcore = pkgs.callPackage ./cwcore.nix { inherit gradle; };
    luckperms = (import ./luckperms.nix).all pkgs;
  };
  cubic-lobby = pkgs.callPackage ./cubic-lobby.nix { inherit gradle jre; };
}
