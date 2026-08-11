{
  config,
  culib,
  lib,
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

  # please don't lock me out.
  config.networking.firewall.checkReversePath = lib.mkForce false;
}
