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
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nix-minecraft,
      agenix,
      microvm,
      deploy-rs,
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

      pkgs-sys-agnostic =
        system:
        import nixpkgs {
          inherit system overlays;
          config.allowUnfreePredicate =
            pkg:
            builtins.elem ((import nixpkgs { inherit system; }).lib.getName pkg) [
              "graalvm-oracle"
            ];
        };

      specialArgs =
        isTest: thisServer:
        deps
        // {
          culib = culib isTest thisServer;
        };

    in
    {
      nixosConfigurations = {
        cubic = nixpkgs.lib.nixosSystem ({
          modules = [
            nixpkgs.nixosModules.readOnlyPkgs
            ./hosts/cubic
          ];

          specialArgs = (specialArgs false "cubic") // {
            pkgs = pkgs-sys-agnostic "x86_64-linux";
          };
        });
        cubic-vm = nixpkgs.lib.nixosSystem ({
          specialArgs = (specialArgs true "cubic") // {
            pkgs = pkgs-sys-agnostic "x86_64-linux";
          };

          modules = [
            nixpkgs.nixosModules.readOnlyPkgs
            ./hosts/cubic
            ./test/vm.nix
          ];
        });
      };

      overlays.default = final: prev: self.legacyPackages.${prev.stdenv.hostPlatform.system};

      deploy.nodes.cubic = {
        # IT WON'T WORK UNLESS YOU DEFINE cubic OUT OF THIS FLAKE (for example in ssh's hosts)
        hostname = "cubic";
        profiles.system = {
          sshUser = "jenya705";
          # FIXME
          interactiveSudo = true;
          confirmTimeout = 120;
          activationTimeout = 1200;
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.cubic;
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = pkgs-sys-agnostic system;
      in
      {
        legacyPackages = ((import pkgs/all-packages.nix) { inherit pkgs; }) // {
          cu_update_secrets = pkgs.callPackage ./test/update_secrets.nix { };
        };
        packages = {
          cu_update_secrets = self.legacyPackages.${system}.cu_update_secrets;
        };
        devShells.default = pkgs.mkShell {
          packages = [
            self.legacyPackages.${system}.cu_update_secrets
          ];

          shellHook = ''
            echo cu_update_secrets is now available!
          '';
        };
      }
    );
}
