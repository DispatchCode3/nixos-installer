{
  description = "Reusable NixOS installation framework";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      lib = nixpkgs.lib;

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = f:
        lib.genAttrs supportedSystems (system: f system);

      mkInstallerLib = system:
        let
          pkgs = import nixpkgs { inherit system; };
        in {
          inherit pkgs;

          mkHostConfig =
            { hostname
            , username
            , host
            , roles ? [ ]
            , stateVersion ? "24.11"
            , extraModules ? [ ]
            }:
            lib.nixosSystem {
              inherit system;
              specialArgs = {
                inherit inputs self username host roles;
              };
              modules =
                [
                  ./modules/base.nix
                  (./modules/hosts + "/${host}.nix")
                  ({ ... }: {
                    networking.hostName = hostname;

                    users.users.${username} = {
                      isNormalUser = true;
                      extraGroups = [ "wheel" ];
                    };

                    system.stateVersion = stateVersion;
                  })
                ]
                ++ map (role: ./modules/roles/${role}.nix) roles
                ++ extraModules;
            };
        };
    in {
      lib = forAllSystems (system: mkInstallerLib system);

      nixosModules = {
        base = ./modules/base.nix;

        hosts = {
          desktop = ./modules/hosts/desktop.nix;
          laptop = ./modules/hosts/laptop.nix;
          vm = ./modules/hosts/vm.nix;
          portable-usb = ./modules/hosts/portable-usb.nix;
          server = ./modules/hosts/server.nix;
        };

        roles = {
          minimal = ./modules/roles/minimal.nix;
          workstation = ./modules/roles/workstation.nix;
          dev = ./modules/roles/dev.nix;
          gaming = ./modules/roles/gaming.nix;
          vm-host = ./modules/roles/vm-host.nix;
        };
      };

      templates = {
        machine-config = ./templates/machine-config.nix;
      };
    };
}
