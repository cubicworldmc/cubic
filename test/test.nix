{
  pkgs,
  nix-minecraft,
  agenix,
  culib,
  ...
}:
let

  secretValues = import ../secrets/test/values.nix;

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
        ./upload_keys_module.nix
      ];
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
