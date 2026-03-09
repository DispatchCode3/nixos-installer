{ pkgs, ... }:

{
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
  ];
}
