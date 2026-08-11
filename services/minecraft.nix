{
  config,
  lib,
  ...
}:
with lib;
{
  imports = [
    ./env-setup.nix
  ];

  options.services.cubic-minecraft-servers = {
    servers = mkOption {
      default = { };
      type = types.attrsOf (
        types.submodule (
          { name, ... }: {
            options = {
              ageFiles = mkOption {
                type = types.listOf types.str;
                default = [ ];
              };

              additionalEnvVars = mkOption {
                type = types.attrsOf types.str;
              };
            };
          }
        )
      );
    };
  };

  config = {
    services.env-files-setup =
      config.services.cubic-minecraft-servers.servers
      |> lib.mapAttrs' (
        server: conf: {
          name = "minecraft-server-${server}";
          value = {
            wantedBy = [ "minecraft-server-${server}.service" ];
            inherit (conf) ageFiles additionalEnvVars;
            inherit (config.services.minecraft-servers) user group;
          };
        }
      );

    services.minecraft-servers.servers =
      config.services.cubic-minecraft-servers.servers
      |> builtins.mapAttrs (
        server: conf: {
          environmentFile = toString (config.services.env-files-setup."minecraft-server-${server}".path);
        }
      );

    systemd.services =
      config.services.cubic-minecraft-servers.servers
      |> lib.mapAttrs' (
        server: conf:
        lib.nameValuePair "minecraft-server-${server}" {
          after = [ "NetworkManager.service" ];
          wants = [ "NetworkManager.service" ];
        }
      );
  };
}
