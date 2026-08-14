{ pkgs }:
let
  gradle = pkgs.gradle_9;
  jre = pkgs.graalvmPackages.graalvm-oracle_25;
in
{
  plugins = {
    cwcore = pkgs.callPackage ./cwcore.nix { inherit gradle; };
    luckperms = (import ./luckperms.nix).all pkgs;
    cubic-auth = pkgs.callPackage ./cubic-auth.nix { inherit gradle; };
    prism-paper = pkgs.callPackage ./prism.nix { inherit gradle; };
    nbt-api = pkgs.callPackage ./nbt-api.nix { };
    tcpshield = pkgs.callPackage ./tcpshield.nix { };
    skins-restorer = pkgs.callPackage ./skins-restorer.nix { };
  };
  minecraftServers = {
    cubic-lobby = pkgs.callPackage ./cubic-lobby.nix { inherit gradle jre; };
    leaf = pkgs.callPackage ./leaf.nix { inherit jre; };
    nano-limbo = pkgs.callPackage ./nano-limbo.nix { inherit jre; };
  };
}
