{
  pkgs,
  lib,
  culib,
  ...
}:
{
  imports = [
    ../minecraft.nix
  ];

  config.services.cubic-minecraft-servers.servers.vanilla = {
    ageFiles = [
      "cubic-vanilla-port"
      "forwarding-secret"
      "mysql-luckperms-user-pass"
    ];
  };

  config.services.minecraft-servers = {
    enable = true;
    eula = true;
    servers.vanilla = {
      enable = true;
      package = pkgs.paperServers.paper-26_2;
      jvmOpts = "-Xmx2G";
      serverProperties = {
        online-mode = false;
        server-port = "@cubicVanillaPort@";
      };
      symlinks = {
        "plugins/cwcore.jar" = "${pkgs.plugins.cwcore}/bukkit.jar";
        "plugins/luckperms.jar" = pkgs.plugins.luckperms.bukkit;
      };
      files = {
        "config/paper-global.yml" = {
          format = pkgs.formats.yaml { };
          value = (import ./paper-global.nix) { };
        };
        "config/luckperms/config.yml" = {
          format = pkgs.formats.yaml { };
          value = (import ../proxy/luckperms-config.nix) { inherit lib culib; };
        };
      };
    };
  };
}
