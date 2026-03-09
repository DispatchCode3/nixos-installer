{
  description = "Reusable NixOS installation framework";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = f:
        lib.genAttrs supportedSystems (system: f system);

      hostModules = {
        desktop = ./modules/hosts/desktop.nix;
        laptop = ./modules/hosts/laptop.nix;
        vm = ./modules/hosts/vm.nix;
        portable-usb = ./modules/hosts/portable-usb.nix;
        server = ./modules/hosts/server.nix;
      };

      roleModules = {
        minimal = ./modules/roles/minimal.nix;
        workstation = ./modules/roles/workstation.nix;
        dev = ./modules/roles/dev.nix;
        gaming = ./modules/roles/gaming.nix;
        vm-host = ./modules/roles/vm-host.nix;
      };

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
                inherit inputs self hostname username host roles;
              };

              modules =
                [
                  self.nixosModules.base
                  hostModules.${host}

                  ({ ... }: {
                    networking.hostName = hostname;

                    users.users.${username} = {
                      isNormalUser = true;
                      extraGroups = [ "wheel" ];
                    };

                    system.stateVersion = stateVersion;
                  })
                ]
                ++ map (role: roleModules.${role}) roles
                ++ extraModules;
            };
        };
    in {
      lib = forAllSystems mkInstallerLib;

      nixosModules = {
        base = ./modules/base.nix;
        hosts = hostModules;
        roles = roleModules;
      };

      templates = {
        machine-config = ./templates/machine-config.nix;
      };
    };
}
