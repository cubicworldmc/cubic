{ pkgs }:
let
  jre = pkgs.jdk25;
  gradle = pkgs.gradle_9;
in
{
  plugins = {
    cwcore = pkgs.callPackage ./cwcore.nix { inherit gradle; };
    luckperms = (import ./luckperms.nix).all pkgs;
    cubic-auth = pkgs.callPackage ./cubic-auth.nix { inherit gradle; };
  };
  cubic-lobby = pkgs.callPackage ./cubic-lobby.nix { inherit gradle jre; };
  nano-limbo = pkgs.callPackage ./nano-limbo.nix { inherit jre; };
}
