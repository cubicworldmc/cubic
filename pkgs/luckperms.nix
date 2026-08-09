rec {
  bukkit =
    { fetchurl, lib }:
    fetchurl {
      url = "https://download.luckperms.net/1658/bukkit/loader/LuckPerms-Bukkit-5.5.71.jar";
      sha256 = lib.fakeSha256;
    };
  velocity =
    { fetchurl, lib }:
    fetchurl {
      url = "https://download.luckperms.net/1658/velocity/LuckPerms-Velocity-5.5.71.jar";
      sha256 = "o6yS704p/Yek1wbckkRf2UbxyvHTNSbKGEIqYlVPoYo=";
    };
  all = pkgs: {
    bukkit = pkgs.callPackage bukkit { };
    velocity = pkgs.callPackage velocity { };
  };
}
