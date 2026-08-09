{
  description = "configuration for cubic server(s)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-minecraft.url = "github:cubicworldmc/nix-minecraft";
    nix-minecraft.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    microvm.url = "github:microvm-nix/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nix-minecraft,
      agenix,
      microvm,
    }:
    let
      culib = (import ./lib);

      overlays = [
        nix-minecraft.overlay
        agenix.overlays.default
        self.overlays.default
      ];

      deps = {
        inherit nix-minecraft agenix microvm;
      };

      specialArgs =
        isTest: thisServer:
        deps
        // {
          culib = culib isTest thisServer;
        };

      nixosConfigurationsModule =
        { nixpkgs, ... }:
        {
          nixpkgs.overlays = overlays;
        };
    in
    {
      nixosConfigurations = {
        cubic = nixpkgs.lib.nixosSystem ({
          modules = [
            ./hosts/cubic
            nixosConfigurationsModule
          ];

          specialArgs = specialArgs false "cubic";
        });
        cubic-vm = nixpkgs.lib.nixosSystem ({
          specialArgs = specialArgs true "cubic";

          modules = [
            ./hosts/cubic
            ./test/vm.nix
            nixosConfigurationsModule
          ];
        });
      };
      overlays.default = final: prev: self.packages.${prev.stdenv.hostPlatform.system};
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = (
          import nixpkgs {
            inherit system overlays;
          }
        );
      in
      {
        packages = ((import pkgs/all-packages.nix) { inherit pkgs; }) // {
          cu_update_secrets = pkgs.callPackage ./test/update_secrets.nix { };
        };
        devShells.default = pkgs.mkShell {
          packages = [
            self.packages.${system}.cu_update_secrets
          ];

          shellHook = ''
            echo cu_update_secrets is now available!
          '';
        };
        checks.ultimate-test = (import ./test/test.nix) (
          deps
          // {
            culib = culib true;
          }
        );

      }
    );
}
