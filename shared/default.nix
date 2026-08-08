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

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "pipe-operators"
  ];
}
