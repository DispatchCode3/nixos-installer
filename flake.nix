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
        {
          mkHostConfig =
            { host
            , roles ? [ ]
            , machine ? { }
            , extraModules ? [ ]
            }:
            lib.nixosSystem {
              inherit system;

              specialArgs = {
                inherit inputs self host roles;
              };

              modules =
                [
                  self.nixosModules.base
                  hostModules.${host}

                  ({ lib, ... }: {
                    networking.hostName = lib.mkDefault (machine.hostname or "nixos");

                    users.users = lib.mkIf (machine ? username) {
                      ${machine.username} = {
                        isNormalUser = true;
                        extraGroups = [ "wheel" ];
                      };
                    };

                    time.timeZone = lib.mkIf (machine ? timezone) machine.timezone;
                    i18n.defaultLocale = lib.mkIf (machine ? locale) machine.locale;
                    system.stateVersion = machine.stateVersion or "24.11";
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
