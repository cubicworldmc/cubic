{ microvm, ... }:
{
  imports = [
    microvm.nixosModules.microvm
    ./test_module.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  microvm.interfaces = [
    {
      type = "bridge";
      id = "vm-1";
      bridge = "br0";
      mac = "02:00:00:00:00:01";
    }
  ];

  microvm.shares = [
    {
      tag = "ro-store";
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
    }
  ];

  microvm.mem = 4096; # 4gb
}
