{ pkgs, config, ... }: {
  imports = [
    ./minecraft.nix
  ];

  config.services.cubic-minecraft-servers.servers.lobby = {
    ageFiles = [
      "cubic-lobby-port"
      "forwarding-secret"
    ];
    additionalEnvVars = {
      "CUBIC_LOBBY_WORLD_PATH" = "${config.services.minecraft-servers.dataDir}/lobby/worlds/lobby";
      "CUBIC_LOBBY_SERVER_PORT" = "@cubicLobbyPort@";
      "CUBIC_LOBBY_SECRET_PATH" = config.age.secrets.minecraft-server-lobby-forwarding-secret.path;
    };
  };

  # TODO: do we need to use nix-minecraft here
  config.services.minecraft-servers = {
    enable = true;
    eula = true;
    servers.lobby = {
      enable = true;
      package = pkgs.cubic-lobby;
      jvmOpts = "-Xmx1G";
      extraStartPre = ''
        ${pkgs.coreutils}/bin/mkdir -p ${config.services.minecraft-servers.dataDir}/lobby/worlds/lobby
        ${pkgs.coreutils}/bin/cp -r ${pkgs.cubic-lobby}/worlds/lobby ${config.services.minecraft-servers.dataDir}/lobby/worlds/lobby
      '';
    };
  };
}
