{ pkgs, ... }:

{
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
  ];
}
