{
  culib,
  lib,
  ...
}:
{
  imports = [
    ../../shared/default.nix
    ../../services/minecraft.nix
    ../../services/vanilla.nix
    ../../services/proxy.nix
    ../../services/lobby.nix
    ../../services/mariadb.nix
  ]
  ++ (if culib.isTest then [ ] else [ ./hardware-configuration.nix ]);

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
    networkmanager.enable = true;
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
