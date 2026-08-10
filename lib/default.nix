# TODO: allow nix's lib to be used here
isTest: thisServer: rec {
  inherit isTest thisServer;
  secretPath = secret: if isTest then ../secrets/test/${secret} else ../secrets/prod/${secret};
  isProd = !isTest;
  serverIpSecret = server: if thisServer == server then "localhost-magic" else "${server}-ip";
  serviceServers =
    let
      cubic = "cubic";
    in
    {
      minecraft-server-vanilla = cubic;
      minecraft-server-proxy = cubic;
      minecraft-server-lobby = cubic;
      minecraft-server-limbo = cubic;
      mysql-server-cwcore = cubic;
      mysql-server-cubicauth = cubic;
      mysql-server-luckperms = cubic;
      clickhouse-server-prism = cubic;
    };
  serviceIpSecret = service: serverIpSecret serviceServers.${service};
}
