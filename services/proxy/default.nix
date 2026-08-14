{
  culib,
  pkgs,
  lib,
  config,
  ...
}:
let
  secretPath = secret: config.age.secrets."minecraft-server-proxy-${secret}".path;
in
{
  imports = [
    ../minecraft.nix
  ];

  config.services.cubic-minecraft-servers.servers.proxy = {
    ageFiles = [
      "cubic-proxy-port"
      "cubic-vanilla-port"
      "cubic-lobby-port"
      "cubic-limbo-port"
      (culib.serviceIpSecret "minecraft-server-vanilla")
      (culib.serviceIpSecret "minecraft-server-lobby")
      (culib.serviceIpSecret "minecraft-server-limbo")
      (culib.serviceIpSecret "mysql-server-luckperms")
      (culib.serviceIpSecret "mysql-server-cwcore")
      (culib.serviceIpSecret "mysql-server-cubicauth")
      (culib.serviceIpSecret "mysql-server-skinsrestorer")
      "mysql-cwcore-user-pass"
      "mysql-cubicauth-user-pass"
      "mysql-luckperms-user-pass"
      "mysql-skinsrestorer-user-pass"
    ];
  };

  config.age.secrets =
    [
      "forwarding-secret"
      "cwcore-lists-tcp-server-key"
      "cwcore-vanilla-list-key"
    ]
    |> builtins.map (val: {
      name = "minecraft-server-proxy-${val}";
      value = {
        file = culib.secretPath "${val}.age";
        owner = config.services.minecraft-servers.user;
        group = config.services.minecraft-servers.group;
        mode = "600";
      };
    })
    |> builtins.listToAttrs;

  config.services.minecraft-servers = {
    enable = true;
    eula = true;
    servers.proxy = {
      enable = true;
      package = pkgs.velocityServers.velocity;
      jvmOpts =
        if culib.isProd then
          "-Xmx6G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"
        else
          "-Xmx1G";
      symlinks = {
        "forwarding.secret" = secretPath "forwarding-secret";
        "plugins/cwcore.jar" = "${pkgs.plugins.cwcore}/velocity.jar";
        "plugins/cwcore/lists-tcp.key" = secretPath "cwcore-lists-tcp-server-key";
        "plugins/cwcore/vanilla.key" = secretPath "cwcore-vanilla-list-key";
        "plugins/luckperms.jar" = pkgs.plugins.luckperms.velocity;
        "plugins/cubicauth.jar" = pkgs.plugins.cubic-auth;
        "plugins/tcpshield.jar" = pkgs.plugins.tcpshield;
        "plugins/skinsrestorer.jar" = pkgs.plugins.skins-restorer;
      };
      files = {
        "plugins/cwcore/config.yml" = {
          format = pkgs.formats.yaml { };
          value = (import ./cwcore-config.nix) { inherit lib culib; };
        };
        "velocity.toml" = {
          format = pkgs.formats.toml { };
          value = (import ./velocity.toml.nix) { inherit lib culib; };
        };
        "plugins/cubicauth/config.yml" = {
          format = pkgs.formats.yaml { };
          value = (import ./cubicauth-config.nix) { inherit lib culib; };
        };
        "plugins/luckperms/config.yml" = {
          format = pkgs.formats.yaml { };
          value = (import ./luckperms-config.nix) { inherit lib culib; } // {
            broadcast-received-log-entries = true;
          };
        };
        "plugins/tcpshield/config.toml" = {
          format = pkgs.formats.toml { };
          value = {
            only-allow-proxy-connections = culib.isProd;
            timestamp-validation = "htpdate";
            debug-mode = false;
            enable-geyser-support = false;
            pre-login-event = true;
          };
        };
        "plugins/skinsrestorer/config.yml" = {
          format = pkgs.formats.yaml { };
          value = (import ./skins-restorer-config.nix) { inherit lib culib; };
        };
      };
    };
  };
}
