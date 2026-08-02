{
  lib,
  config,
  pkgs,
  culib,
  nixpkgs,
  ...
}:
let
  owner = "minecraft-vanilla";
  group = "minecraft-vanilla";

  envFileContent = ''
    CUBIC_VANILLA_PORT="@CUBIC_VANILLA_PORT@"
  '';

  envFilePlaceholder =
    pkgs.runCommand "cubic-vanilla-env-file"
      {
        inherit envFileContent;
        passAsFile = [ "envFileContent" ];
      }
      ''
        cp $envFileContentPath $out
      '';

  envFile = "${config.services.minecraft-servers.dataDir}/vanilla-environmentFile";
in
{
  config.nixpkgs.config.allowUnfree = true;

  config.age.secrets.cubic-vanilla-port = {
    file = culib.secretPath "cubic-vanilla-port.age";
    inherit owner group;
  };

  /*
    Systemd loads the environment file BEFORE ExecStartPre, thus we need
    a separate service to actually setup the environment file.

    activationScripts are not a way to go, because agenix setups everything in initrd (activationScripts).
  */
  config.systemd.services.cubic-vanilla-env-file-setup = {
    wantedBy = [
      "multi-user.target"
      "minecraft-server-vanilla.service" # TODO: expose from nix-minecraft
    ];
    after = [
      "run-agenix.d.mount"
    ];
    description = "setup an environment file for vanilla server";
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = lib.getExe (
        pkgs.writeShellApplication {
          name = "cubic-vanilla-env-file-setup-script";
          text = ''
            ${pkgs.coreutils}/bin/cp "${envFilePlaceholder}" "${envFile}"
            ${pkgs.coreutils}/bin/chown ${owner}:${group} "${envFile}"
            ${pkgs.coreutils}/bin/chmod 600 "${envFile}"
            secret=$(cat "${config.age.secrets.cubic-vanilla-port.path}")
            ${pkgs.gnused}/bin/sed -i "s#@CUBIC_VANILLA_PORT@#$secret#" "${envFile}"
          '';
        }
      );
    };
  };

  config.services.minecraft-servers = {
    enable = true;
    eula = true;
    environmentFile = envFile;
    servers.vanilla = {
      enable = true;
      user = owner;
      group = group;
      jvmOpts = "-Xmx2G";
      serverProperties = {
        server-port = "@CUBIC_VANILLA_PORT@";
      };
    };
  };
}
