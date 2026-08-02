{
  pkgs,
  nix-minecraft,
  agenix,
  culib,
  ...
}:
let

  secretValues = import ../secrets/test/values.nix;

  inStore =
    name: pkgs:
    pkgs.runCommand "put-test-${name}-into-store" {
      key = builtins.readFile ./${name};
      passAsFile = [ "key" ];
    } "cp $keyPath $out";

  publicInStore = inStore "id_ed25519.pub";
  privateInStore = inStore "id_ed25519";

in
pkgs.testers.runNixOSTest {
  name = "ultimate-test";
  node = {
    inherit pkgs;
    pkgsReadOnly = false;
    specialArgs = {
      inherit agenix nix-minecraft culib;
    };
  };
  nodes = {
    cubic = { pkgs, ... }: {
      imports = [
        ../hosts/cubic
      ];

      age.identityPaths = [
        (privateInStore pkgs)
      ];

      environment.etc = {
        "ssh/ssh_host_ed25519_key" = {
          source = (privateInStore pkgs);
          mode = "0600";
        };
        "ssh/ssh_host_ed25519_key.pub" = {
          source = (publicInStore pkgs);
          mode = "0644";
        };
      };
    };
  };
  testScript = { ... }: ''
    name = "vanilla"
    grep_logs = lambda expr: f"grep '{expr}' /srv/minecraft/{name}/logs/latest.log"

    cubic.wait_for_unit(f"minecraft-server-{name}.service")
    cubic.wait_for_open_port(${secretValues."cubic-vanilla-port.age"})
    cubic.wait_until_succeeds(grep_logs("Done ([0-9.]\+s)! For help, type \"help\""), timeout=30)
    cubic.succeed(f"test -e /srv/minecraft/{name}/allowed_symlinks.txt")
  '';
}
