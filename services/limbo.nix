{
  pkgs,
  ...
}:
{
  imports = [
    ./minecraft.nix
  ];

  config.services.cubic-minecraft-servers.servers.limbo = {
    ageFiles = [
      "cubic-limbo-port"
      "forwarding-secret"
    ];
  };

  # TODO: do we need to use nix-minecraft here
  config.services.minecraft-servers = {
    enable = true;
    eula = true;
    servers.limbo = {
      enable = true;
      package = pkgs.nano-limbo;
      jvmOpts = "-Xmx1G";
      files = {
        "settings.yml" = {
          format = pkgs.formats.yaml { };
          value = {
            bind = {
              ip = "localhost";
              port = "@cubicLimboPort@";
            };
            maxPlayers = 1000;
            ping = {
              description = "limbo";
              version = "all";
              protocol = -1;
            };
            dimension = "THE_END";
            playerList = {
              enable = false;
              username = "NanoLimbo";
            };
            headerAndFooter = {
              enable = false;
              header = "<white>Welcome!";
              footer = "<gradient:blue:white>NanoLimbo";
            };
            gameMode = 3;
            secureProfile = false;
            brandName = {
              enable = true;
              content = "<blue>NanoLimbo";
            };
            joinMessage = {
              enable = false;
              text = "<white>Welcome to the <gradient:blue:white>NanoLimbo<white>!";
            };
            bossBar = {
              enable = false;
              text = "<white>Welcome to the <gradient:blue:white>NanoLimbo<white>!";
              health = 1;
              color = "BLUE";
              division = "SOLID";
            };
            title = {
              enable = false;
              title = "<white><b>Welcome!";
              subtitle = "<gradient:blue:white>NanoLimbo";
              fadeIn = 10;
              stay = 100;
              fadeOut = 10;
            };
            # info forwarding itself is irrelevant, just that the player has joined from the proxy.
            infoForwarding = {
              type = "MODERN";
              secret = "@forwardingSecret@";
            };
            readTimeout = 30000;
            logPlayersIp = false;
            debugLevel = 2;
            netty = {
              transportType = "EPOLL";
              threads = {
                bossGroup = 1;
                workerGroup = 1;
              };
            };
            traffic = {
              enable = true;
              maxPacketSize = 8192;
              interval = 7;
              maxPacketRate = 500;
              maxPacketBytesRate = 2048;
            };
          };
        };
      };
    };
  };
}
