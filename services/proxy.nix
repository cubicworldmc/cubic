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
    ./minecraft.nix
  ];

  config.services.cubic-minecraft-servers.servers.proxy = {
    ageFiles = [
      "cubic-proxy-port"
      "cubic-vanilla-port"
      "cubic-lobby-port"
      (culib.serviceIpSecret "minecraft-server-vanilla")
      "mysql-cwcore-user-pass"
    ];
  };

  config.age.secrets =
    [
      "forwarding-secret"
      "cwcore-ssl-cert"
      "cwcore-ssl-key"
      "cwcore-ssl-client-cert"
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
      symlinks = {
        "forwarding.secret" = secretPath "forwarding-secret";
        "plugins/cwcore.jar" = "${pkgs.plugins.cwcore}/velocity.jar";
        "plugins/cwcore/cert.pem" = secretPath "cwcore-ssl-cert";
        "plugins/cwcore/key.pem" = secretPath "cwcore-ssl-key";
        "plugins/cwcore/clcert.pem" = secretPath "cwcore-ssl-client-cert";
        "plugins/cwcore/vanilla.key" = secretPath "cwcore-vanilla-list-key";
        "plugins/luckperms.jar" = pkgs.plugins.luckperms.velocity;
      };
      files = {
        "plugins/cwcore/config.yml" = {
          format = pkgs.formats.yaml { };
          value = {
            mysql = {
              host = "@${lib.strings.toCamelCase (culib.serviceIpSecret "mysql-server-cwcore")}@:3306";
              username = "cwcore";
              password = "@mysqlCwcoreUserPass@";
              database = "cwcore";
              ssl = true;
            };
            ignored-servers = [ "reg-limbo" ];
            colors = {
              "reputation > 4" = "#6495ED";
              "reputation > 9" = "#7FFF00";
              "reputation > 14" = "#B8860B";
            };
            premium-permission = "group.premium";
            premium = {
              custom-color = true;
            };
            http = {
              port = 8080;
              key-file = "key.pem";
              cert-file = "cert.pem";
              client-cert-file = "clcert.pem";
            };
            lists = {
              vanilla = {
                required-to-join = [ "vanilla" ];
                acceptance = {
                  kind = "lc";
                  url = "https://google.com";
                  key-file = "vanilla.key";
                };
              };
            };
          };
        };
        "velocity.toml" = {
          format = pkgs.formats.toml { };
          value = {
            config-version = "2.8";
            bind = "0.0.0.0:@cubicProxyPort@";
            motd = "cubic";
            show-max-players = 500;
            online-mode = false;
            force-key-authentication = true;
            prevent-client-proxy-connections = false;
            player-info-forwarding-mode = "modern";
            forwarding-secret-file = "forwarding.secret";
            announce-forge = false;
            kick-existing-players = false;
            ping-passthrough = "DISABLED";
            sample-players-in-ping = false;
            enable-player-address-logging = true;
            packet-limiter = {
              interval = 7;
              packets-per-second = -1;
              bytes-per-second = -1;
              decompressed-bytes-per-second = 5242880;
            };
            servers = {
              lobby = "@${lib.strings.toCamelCase (culib.serviceIpSecret "minecraft-server-lobby")}@:@cubicLobbyPort@";
              vanilla = "@${lib.strings.toCamelCase (culib.serviceIpSecret "minecraft-server-vanilla")}@:@cubicVanillaPort@";
              try = [
                "lobby"
                "vanilla"
              ];
            };
            forced-hosts = { };
            advanced = {
              compression-threshold = 256;
              compression-level = -1;
              login-ratelimit = 3000;
              connection-timeout = 5000;
              read-timeout = 30000;
              haproxy-protocol = false;
              tcp-fast-open = false;
              bungee-plugin-message-channel = true;
              show-ping-requests = false;
              failover-on-unexpected-server-disconnect = true;
              announce-proxy-commands = true;
              log-command-executions = false;
              log-player-connections = true;
              accepts-transfers = false;
              enable-reuse-port = false;
              command-rate-limit = 50;
              forward-commands-if-rate-limited = true;
              kick-after-rate-limited-commands = 0;
              tab-complete-rate-limit = 10;
              kick-after-rate-limited-tab-completes = 0;
            };
            query = {
              enabled = false;
              port = 25565;
              map = "Velocity";
              show-plugins = false;
            };
          };
        };
      };
    };
  };
}
