{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "cubic";
  networking.networkManager.enable = true;

  time.timeZone = "GMT";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.jenya705 = {
    isNormalUser = true;
    description = "jenya705";
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFppFGOyVGxz4HjLPNpqZpSI7Uh+OFie8cXMQCyN+dwV"
    ];
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  environment.systemPackages = with pkgs; [
    wget
    net-tools
    git
  ];

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      MaxAuthTries = 10;
      AllowUsers = ["jenya705"];
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 25565];
    allowedUDPPorts = [22];
  };

  # DO NOT CHANGE
  system.stateVersion = "25.11";
}
