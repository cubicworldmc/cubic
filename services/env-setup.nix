{
  lib,
  culib,
  pkgs,
  config,
  ...
}:
with lib;
{
  options.services.env-files-setup = mkOption {
    default = { };
    type = types.attrsOf (
      types.submodule (
        { name, ... }: {
          options = {
            user = mkOption {
              type = types.str;
            };
            group = mkOption {
              type = types.str;
              default = "root";
            };
            path = mkOption {
              type = types.str;
              default = "/run/env-files/${name}";
            };
            ageFiles = mkOption {
              type = types.listOf types.str;
              default = [ ];
            };
            additionalEnvVars = mkOption {
              type = types.attrsOf types.str;
              default = { };
            };
            wantedBy = mkOption {
              type = types.listOf types.str;
              default = [ ];
            };
          };
        }
      )
    );
  };

  config = {
    age.secrets =
      config.services.env-files-setup
      |> mapAttrsToList (
        name: conf:
        conf.ageFiles
        |> lists.uniqueStrings
        |> builtins.map (file: {
          "${name}-${file}" = {
            file = culib.secretPath "${file}.age";
            owner = conf.user;
            group = conf.group;
          };
        })
      )
      |> builtins.concatLists
      |> mergeAttrsList;

    systemd.services =
      config.services.env-files-setup
      |> mapAttrsToList (
        name: conf:
        let
          envFilePlaceholderText =
            (
              (
                conf.ageFiles
                |> builtins.map (
                  file:
                  let
                    camel = strings.toCamelCase file;
                  in
                  "${camel}=@${camel}@"
                )
              )
              ++ (conf.additionalEnvVars |> mapAttrsToList (name: var: "${name}=${var}"))
            )
            |> builtins.concatStringsSep "\n";
          envFilePlaceholder = pkgs.writeText "${name}-env-file-placeholder" envFilePlaceholderText;
        in
        {
          "${name}-env-file-setup" = mkIf ("" != lib.strings.trim envFilePlaceholderText) {
            enable = true;
            wantedBy = conf.wantedBy;
            after = [ "run-agenix.d.mount" ];
            description = "${name} environment file setup";
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = "yes";
              ExecStart = lib.getExe (
                pkgs.writeShellApplication {
                  name = "${name}-env-file-setup-script";
                  text =
                    [
                      ''
                        ${pkgs.coreutils}/bin/mkdir -p "${conf.path}"
                        ${pkgs.coreutils}/bin/rm -rf "${conf.path}"
                        ${pkgs.coreutils}/bin/cp "${envFilePlaceholder}" "${conf.path}"
                        ${pkgs.coreutils}/bin/chown ${conf.user}:${conf.group} "${conf.path}"
                        ${pkgs.coreutils}/bin/chmod 600 "${conf.path}"
                      ''
                    ]
                    ++ (
                      conf.ageFiles
                      |> builtins.map (file: ''
                        secret=$(${pkgs.coreutils}/bin/cat "${config.age.secrets."${name}-${file}".path}")
                        ${pkgs.gnused}/bin/sed -i "s#@${strings.toCamelCase file}@#$secret#" "${conf.path}"
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
  };
}
