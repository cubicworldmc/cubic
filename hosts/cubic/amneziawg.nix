{
  config,
  culib,
  lib,
  pkgs,
  ...
}:
{
  config.age.secrets.amneziawg-conf-cubic = {
    file = culib.secretPath "amneziawg-conf-cubic.age";
    owner = "root";
    group = "root";
  };

  config.networking.wg-quick.interfaces.wg0 = {
    type = "amneziawg";
    configFile = config.age.secrets.amneziawg-conf-cubic.path;
  };

  config.networking.nftables.enable = true;

  config.networking.nftable.ruleset = ''
    table inet vpn {
      chain output {
        type route hook output priority mangle;
        meta skuid {
          1001,
          1002
        } meta mark set 0x100;
      }  
    }
  '';

  config.networking.firewall.checkReversePath = lib.mkForce false;
}
