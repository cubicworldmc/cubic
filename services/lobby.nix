{ pkgs, ... }: {
  imports = [
    ./minecraft.nix
  ];

  config.services.cubic-minecraft-servers.servers.lobby = {
    ageFiles = [
      "cubic-lobby-port"
      "forwarding-secret"
    ];
  };

  # TODO: use real lobby
  config.services.minecraft-servers = {
    enable = true;
    eula = true;
    servers.lobby = {
      enable = true;
      package = pkgs.paperServers.paper-26_2;
      jvmOpts = "-Xmx2G";
      serverProperties = {
        online-mode = false;
        server-port = "@cubicLobbyPort@";
      };
      symlinks = {
        "plugins/cwcore.jar" = "${pkgs.plugins.cwcore}/bukkit.jar";
      };
      files = {
        "config/paper-global.yml" = {
          format = pkgs.formats.yaml { };
          value = {
            proxies.velocity = {
              enabled = true;
              secret = "@forwardingSecret@";
            };
          };
        };
      };
    };
  };
}
