let
  meta =
    lib: with lib; {
      license = licenses.mit;
    };
in
rec {
  bukkit =
    { fetchurl, lib }:
    fetchurl {
      url = "https://download.luckperms.net/1658/bukkit/loader/LuckPerms-Bukkit-5.5.71.jar";
      sha256 = "Sc7LZvof0ioTMDmkkOnB5QlaI4581m650qFv5siXVQ0=";
      meta = meta lib;
    };
  velocity =
    { fetchurl, lib }:
    fetchurl {
      url = "https://download.luckperms.net/1658/velocity/LuckPerms-Velocity-5.5.71.jar";
      sha256 = "o6yS704p/Yek1wbckkRf2UbxyvHTNSbKGEIqYlVPoYo=";
      meta = meta lib;
    };
  all = pkgs: {
    bukkit = pkgs.callPackage bukkit { };
    velocity = pkgs.callPackage velocity { };
  };
}
