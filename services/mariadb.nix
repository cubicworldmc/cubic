{
  lib,
  pkgs,
  config,
  culib,
  ...
}:
let
  mariadbPkg = pkgs.mariadb;
  secretName = val: "mysql-${val}-user-pass";
  users = [
    "cwcore"
    "cubicauth"
    "luckperms"
  ];
in
{
  config.services.mysql = {
    enable = true;
    package = mariadbPkg;
  };

  config.age.secrets =
    users
    |> builtins.map (val: {
      name = secretName val;
      value = {
        file = culib.secretPath "${secretName val}.age";
        owner = "root";
        group = "root";
      };
    })
    |> builtins.listToAttrs;

  config.systemd.services.mysql-setup =
    let
      secretPath = val: config.age.secrets.${secretName val}.path;

      ExecStart = lib.getExe (
        pkgs.writeShellApplication {
          name = "mysql-setup-script";
          text = ''
            (
                        ${
                          users
                          |> builtins.map (
                            val:
                            (
                              [
                                ''
                                  echo "CREATE DATABASE IF NOT EXISTS ${val};"
                                ''
                              ]
                              ++ (
                                [
                                  "%"
                                  "localhost"
                                ]
                                |> builtins.map (host: ''
                                  echo "CREATE USER IF NOT EXISTS '${val}'@'${host}' IDENTIFIED BY '$(cat ${secretPath val})';"
                                  echo "SET PASSWORD FOR '${val}'@'${host}' = PASSWORD('$(cat ${secretPath val})');"
                                  echo "GRANT ALL PRIVILEGES ON ${val}.* TO '${val}'@'${host}';"
                                '')
                              )
                              ++ [
                                (if culib.isTest then "" else "rm ${secretPath val}")
                              ]
                            )
                            |> builtins.concatStringsSep "\n"
                          )
                          |> builtins.concatStringsSep "\n"
                        }
                      ) | ${mariadbPkg}/bin/mariadb -N 
          '';
        }
      );
    in
    {
      description = "Mysql setup";
      wants = [
        "mysql.service"
        "run-agenix.d.mount"
      ];
      after = [
        "mysql.service"
      ];
      before = [
        "minecraft-server-proxy.service" # FIXME: workaround for now
      ];
      wantedBy = [
        "multi-user.target"
        "minecraft-server-proxy.service"
      ];
      serviceConfig = {
        inherit ExecStart;
        User = "root";
        RemainAfterExit = true;
      };
    };
}
