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
      "clickhouse-http-port"
      (culib.serviceIpSecret "mysql-server-luckperms")
      (culib.serviceIpSecret "clickhouse-server-prism")
    ];
  };

  config.services.minecraft-servers = {
    enable = true;
    eula = true;
    servers.vanilla = {
      enable = true;
      package = pkgs.minecraftServers.leaf;
      jvmOpts =
        if culib.isProd then
          "-Xms16G -Xmx16G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -DLeaf.enableFMA -DLeaf.enable-io-uring -XX:+UseDynamicNumberOfGCThreads -XX:+UseLargePages -XX:+AlwaysActAsServerClassMachine -Dgraal.CompilerConfiguration=enterprise -Dgraal.ShowConfiguration=info"
        else
          "-Xmx3G";
      serverProperties = {
        online-mode = false;
        server-port = "@cubicVanillaPort@";
        use-native-transport = true;
        network-compression-threshold = -1;
      };
      symlinks = {
        "plugins/cwcore.jar" = "${pkgs.plugins.cwcore}/bukkit.jar";
        "plugins/luckperms.jar" = pkgs.plugins.luckperms.bukkit;
        "plugins/prism.jar" = pkgs.plugins.prism-paper;
        "plugins/nbt-api.jar" = pkgs.plugins.nbt-api;
        "plugins/skinsrestorer.jar" = pkgs.plugins.skins-restorer;
        "confirm_world_folder_migration" = "${
          pkgs.callPackage (
            { writeShellApplication }:
            writeShellApplication {
              name = "confirm-world-folder-migration";
              text = ''
                tmux -S /run/minecraft/vanilla.sock send-keys C-u confirm Enter
              '';
            }
          ) { }
        }/bin/confirm-world-folder-migration";
      };
      files = {
        "config/paper-global.yml" = {
          format = pkgs.formats.yaml { };
          value = (import ./paper-global.nix) { };
        };
        "config/gale-global.yml" = {
          format = pkgs.formats.yaml { };
          value = (import ./gale-global.nix) { };
        };
        "config/leaf-global.yml" = {
          format = pkgs.formats.yaml { };
          value = (import ./leaf-global.nix) { };
        };
        "config/paper-world-defaults.yml" = {
          format = pkgs.formats.yaml { };
          value = (import ./paper-world-defaults.nix) { };
        };
        # "world/dimensions/minecraft/the_nether/paper-world.yml" = {
        #   format = pkgs.formats.yaml { };
        #   value = (import ./paper-nether-world.nix) { };
        # };
        # "world/dimensions/minecraft/the_end/paper-world.yml" = {
        #   format = pkgs.formats.yaml { };
        #   value.anticheat.anti-xray.enabled = false;
        # };
        "plugins/LuckPerms/config.yml" = {
          format = pkgs.formats.yaml { };
          value = (import ../proxy/luckperms-config.nix) { inherit lib culib; };
        };
        "plugins/prism/prism.conf" = pkgs.writeText "prism.conf" (builtins.readFile ./prism.conf);
        "plugins/prism/storage.conf" = pkgs.writeText "prism-storage.conf" (
          (import ./prism-storage.conf.nix) { inherit lib culib; }
        );
        "plugins/skinsrestorer/config.yml" = {
          format = pkgs.formats.yaml { };
          value = (import ../proxy/skins-restorer-config.nix) { inherit lib culib; };
        };
      };
    };
  };
}
