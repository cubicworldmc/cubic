# Just some configuration needed to look after the servers when needed
{ pkgs, ... }: {
  users.users.jenya705 = {
    isNormalUser = true;
    description = "jenya705";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFppFGOyVGxz4HjLPNpqZpSI7Uh+OFie8cXMQCyN+dwV"
    ];
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  environment.systemPackages = with pkgs; [
    git
    tmux
    tcpdump
  ];

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      MaxAuthTries = 10;
      AllowUsers = [ "jenya705" ];
    };
  };
}
