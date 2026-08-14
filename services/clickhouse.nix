{
  config,
  ...
}:
let
  users = [
    "prism"
  ];
in
{
  imports = [
    ./env-setup.nix
  ];

  config.services.env-files-setup.clickhouse = {
    user = "clickhouse";
    ageFiles = [
      "clickhouse-tcp-port"
      "clickhouse-http-port"
      "clickhouse-prism-user-pass"
    ];
  };

  config.services.clickhouse = {
    enable = true;

    extraServerConfig = ''
      <clickhouse>
        <tcp_port from_env="clickhouseTcpPort"/>
        <http_port from_env="clickhouseHttpPort"/>
      </clickhouse>
    '';

    extraUsersConfig = ''
      <clickhouse>
        <users>
          ${
            users
            |> builtins.map (user: ''
              <${user}>
                <password from_env="clickhousePrismUserPass"/>
                <grants>
                  <query>GRANT ALL ON default.*</query>
                </grants>
              </${user}>
            '')
            |> builtins.concatStringsSep "\n"
          }
        </users>
      </clickhouse>
    '';
  };

  config.systemd.services.clickhouse = {
    wants = [
      "clickhouse-env-file-setup.service"
    ];
    after = [
      "clickhouse-env-file-setup.service"
    ];
    before = [
      "minecraft-server-vanilla.service"
    ];
    wantedBy = [
      "minecraft-server-vanilla.service"
    ];
    serviceConfig.EnvironmentFile = config.services.env-files-setup.clickhouse.path;
  };
}
