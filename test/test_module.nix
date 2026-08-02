{ pkgs, culib, ... }:
let
  inStore =
    name:
    pkgs.runCommand "put-test-${name}-into-store" {
      key = builtins.readFile ./${name};
      passAsFile = [ "key" ];
    } "cp $keyPath $out";

  publicInStore = inStore "id_ed25519.pub";
  privateInStore = inStore "id_ed25519";
in
{
  assertions = [
    {
      assertion = culib.isTest;
      message = "It is generally not preferred to run this module in non-testing environment";
    }
  ];

  age.identityPaths = [
    privateInStore
  ];

  users.users.test = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    password = "test";
  };

  environment.etc = {
    "ssh/ssh_host_ed25519_key" = {
      source = privateInStore;
      mode = "0600";
    };
    "ssh/ssh_host_ed25519_key.pub" = {
      source = publicInStore;
      mode = "0644";
    };
  };
}
