{
  description = "configuration for cubic server(s)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-minecraft.url = "github:cubicworldmc/nix-minecraft";
    agenix.url = "github:ryantm/agenix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nix-minecraft,
      agenix,
    }:
    let
      culib = isTest: (import ./lib) isTest;
      buildArgs =
        conf:
        conf
        // {
          specialArgs = {
            inherit nix-minecraft agenix;
            culib = culib false;
          };
        };
    in
    {
      nixosConfigurations = {
        cubic = nixpkgs.lib.nixosSystem (buildArgs {
          modules = [ ./hosts/cubic ];
        });
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = (
          import nixpkgs {
            inherit system;
            overlays = [
              agenix.overlays.default
              nix-minecraft.overlays.default
            ];
          }
        );
      in
      {
        packages.cu_update_secrets = pkgs.callPackage ./test/update_secrets.nix { };
        devShells.default = pkgs.mkShell {
          packages = [
            self.packages.${system}.cu_update_secrets
          ];

          shellHook = ''
            echo cu_update_secrets is now available!
          '';
        };
        checks.ultimate-test = (import ./test/test.nix) ({
          inherit
            self
            nix-minecraft
            agenix
            pkgs
            ;
          culib = culib true;
        });

      }
    );
}
