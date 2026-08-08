{
  config,
  lib,
  options,
  pkgs,
  culib,
  ...
}:
with lib;
{
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
            };
          }
        )
      );
    };
  };

  config =
    let
      minecraft-servers-conf = name: config.services.minecraft-servers.servers.${name};

      envFilePlaceholderContent =
        ageFiles:
        ageFiles
        |> builtins.map (
          file:
          let
            camel = strings.toCamelCase file;
          in
          "${camel}=@${camel}@"
        )
        |> builtins.concatStringsSep "\n";

      secretName = name: file: "minecraft-server-${name}-${file}";

      envFilePlaceholder =
        name:
        pkgs.runCommand "minecraft-server-${name}-env-file" {
          cont = envFilePlaceholderContent config.services.cubic-minecraft-servers.servers.${name}.ageFiles;
          passAsFile = [ "cont" ];
        } "${pkgs.coreutils}/bin/cp $contPath $out";

      envFilePath = name: "${config.services.minecraft-servers.dataDir}/${name}-environment-file";

      any = list: builtins.length list > 0;
    in
    {
      age.secrets =
        config.services.cubic-minecraft-servers.servers # AttrSet
        |> mapAttrsToList (
          server: conf:
          conf.ageFiles
          |> lists.uniqueStrings
          |> builtins.map (file: {
            ${secretName server file} = {
              file = culib.secretPath "${file}.age";
              owner = config.services.minecraft-servers.user;
              group = config.services.minecraft-servers.group;
            };
          })
        ) # List of List of AttrSet
        |> builtins.concatLists # List of AttrSet
        |> mergeAttrsList; # AttrSet

      systemd.services =
        config.services.cubic-minecraft-servers.servers
        |> mapAttrsToList (
          server: conf:
          let
            owner = config.services.minecraft-servers.user;
            group = config.services.minecraft-servers.group;
            thisEnvFilePath = toString (envFilePath server);
          in
          {
            /*
              Systemd loads the environment file BEFORE ExecStartPre, thus we need
              a separate service to actually setup the environment file.

              activationScripts are not a way to go, because agenix setups everything in initrd (activationScripts).
            */
            "cubic-${server}-env-file-setup" = mkIf (any conf.ageFiles) {
              wantedBy = [
                "minecraft-server-${server}.service" # TODO: expose from nix-minecraft
              ];
              after = [
                "run-agenix.d.mount"
              ];
              description = "setup for vanilla's environment file";
              enable = true;
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = "yes";
                ExecStart = lib.getExe (
                  pkgs.writeShellApplication {
                    name = "cubic-${server}-env-file-setup-script";
                    text =
                      [
                        ''
                          ${pkgs.coreutils}/bin/cp "${envFilePlaceholder server}" "${thisEnvFilePath}"
                          ${pkgs.coreutils}/bin/chown ${owner}:${group} "${thisEnvFilePath}"
                          ${pkgs.coreutils}/bin/chmod 600 "${thisEnvFilePath}"
                        ''
                      ]
                      ++ (
                        conf.ageFiles
                        |> builtins.map (file: ''
                          secret=$(${pkgs.coreutils}/bin/cat "${config.age.secrets.${secretName server file}.path}")
                          ${pkgs.gnused}/bin/sed -i "s#@${strings.toCamelCase file}@#$secret#" "${thisEnvFilePath}"
                        '')
                      )
                      |> builtins.concatStringsSep "\n";
                  }
                );
              };
            };
          }
        )
        |> mergeAttrsList;

      services.minecraft-servers.servers =
        config.services.cubic-minecraft-servers.servers
        |> builtins.mapAttrs (
          server: conf:
          mkIf (any conf.ageFiles) ({
            environmentFile = toString (envFilePath server);
          })
        );
    };
}
