{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./minecraft.nix
  ];

  config.services.cubic-minecraft-servers.servers.lobby = {
    ageFiles = [
      "cubic-lobby-port"
      "forwarding-secret"
    ];
    additionalEnvVars = {
      "CUBIC_LOBBY_WORLD_PATH" = "./world/lobby";
      "CUBIC_LOBBY_SERVER_PORT" = "@cubicLobbyPort@";
      "CUBIC_LOBBY_SECRET_PATH" = config.age.secrets.minecraft-server-lobby-forwarding-secret.path;
      "CUBIC_LOBBY_CONNECT_SERVER" = "vanilla";
    };
  };

  # TODO: do we need to use nix-minecraft here
  config.services.minecraft-servers = {
    enable = true;
    eula = true;
    servers.lobby = {
      enable = true;
      package = pkgs.minecraftServers.cubic-lobby;
      jvmOpts = "-Xmx1G";
      extraStopPre = ''
        kill "$1"
      '';
      extraStartPre =
        let
          worldInSrv = "${config.services.minecraft-servers.dataDir}/lobby/world";
        in
        ''
          ${pkgs.coreutils}/bin/mkdir -p ${worldInSrv}/lobby
          ${pkgs.coreutils}/bin/cp -r --dereference ${pkgs.minecraftServers.cubic-lobby}/worlds/lobby ${worldInSrv} 
          ${pkgs.coreutils}/bin/chmod +w -R ${worldInSrv}/lobby
        '';
    };
  };
}
