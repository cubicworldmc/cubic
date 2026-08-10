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
      "clickhouse-prism-user-pass"
      (culib.serviceIpSecret "mysql-server-luckperms")
      (culib.serviceIpSecret "clickhouse-server-prism")
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
        "plugins/prism.jar" = pkgs.plugins.prism-paper;
        "plugins/nbt-api.jar" = pkgs.plugins.nbt-api;
      };
      files = {
        "config/paper-global.yml" = {
          format = pkgs.formats.yaml { };
          value = (import ./paper-global.nix) { };
        };
        "plugins/LuckPerms/config.yml" = {
          format = pkgs.formats.yaml { };
          value = (import ../proxy/luckperms-config.nix) { inherit lib culib; };
        };
        "plugins/prism/prism.conf" = pkgs.writeText "prism.conf" (builtins.readFile ./prism.conf);
        "plugins/prism/storage.conf" = pkgs.writeText "prism-storage.conf" (
          (import ./prism-storage.conf.nix) { inherit lib culib; }
        );
      };
    };
  };
}
