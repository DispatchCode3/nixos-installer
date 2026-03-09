{ inputs, ... }:
{
  outputs = { self, nixos-installer, ... }:
    let
      system = "{{SYSTEM}}";
    in {
      nixosConfigurations.{{CONFIG_NAME}} =
        nixos-installer.lib.${system}.mkHostConfig {
          host = "{{HOST}}";
          roles = [
{{ROLES}}
          ];

          machine = {
            hostname = "{{HOSTNAME}}";
            username = "{{USERNAME}}";
            timezone = "{{TIMEZONE}}";
            locale = "{{LOCALE}}";
            stateVersion = "{{STATE_VERSION}}";
          };
        };
    };
}
