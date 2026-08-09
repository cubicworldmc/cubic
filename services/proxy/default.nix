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
      "mysql-cwcore-user-pass"
      "mysql-cubicauth-user-pass"
      "mysql-luckperms-user-pass"
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
        "plugins/cubicauth.jar" = pkgs.plugins.cubic-auth;
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
      };
    };
  };
}
