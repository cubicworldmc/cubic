{
  nix-minecraft,
  agenix,
  ...
}:
{
  imports = [
    agenix.nixosModules.default
    nix-minecraft.nixosModules.minecraft-servers
    ./jenya705.nix
  ];

  nixpkgs.overlays = [ nix-minecraft.overlay ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "pipe-operators"
  ];
}
