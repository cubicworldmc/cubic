{
  culib,
  lib,
  ...
}:
{
  imports = [
    ../../shared/default.nix
    ../../services/minecraft.nix
    ../../services/vanilla
    ../../services/proxy
    ../../services/lobby.nix
    ../../services/limbo.nix
    ../../services/mariadb.nix
    ../../services/clickhouse.nix
  ]
  ++ (lib.mkOptional culib.isProd [
    ./hardware-configuration.nix
    ./amneziawg.nix
  ]);

  boot.loader = lib.mkIf culib.isProd {
    grub = {
      enable = true;
      useOSProber = true;
      efiSupport = true;
      device = "nodev";
    };
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "cubic";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        8080
        25565
      ];
      allowedUDPPorts = [
        22
        8080
        25565
      ];
    };
  };

  system.stateVersion = "26.11";
}
