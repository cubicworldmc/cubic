{
  config,
  culib,
  lib,
  pkgs,
  ...
}:
let
  confPath = "/run/awg0-final.conf";
  additionalInterface = ''
    Table = 52111

    PostUp = ip rule add priority 100 gid 30000 table 52111
    PreDown = ip rule del priority 100 gid 30000 table 52111
  '';
in
{
  config.age.secrets.amneziawg-conf-cubic = {
    file = culib.secretPath "amneziawg-conf-cubic.age";
    owner = "root";
    group = "root";
  };

  config.systemd.services.amneziawg-conf-setup = {
    before = [ "wg-quick-awg0.service" ];
    wantedBy = [ "wg-quick-awg0.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };

    script = ''
      to_ins = "${additionalInterface}"
      ${pkgs.coreutils}/bin/cp ${config.age.secrets.amneziawg-conf-cubic.path} ${confPath}
      ${pkgs.gnused}/bin/sed -i "s#@ADDITIONAL_INTERFACE@#$to_ins" "${confPath}"
    '';
  };

  config.networking.wg-quick.interfaces.awg0 = {
    type = "amneziawg";
    configFile = confPath;
  };

  config.networking.firewall.checkReversePath = lib.mkForce false;
}
