{
  networking.hostName = "{{HOSTNAME}}";

  time.timeZone = "{{TIMEZONE}}";
  i18n.defaultLocale = "{{LOCALE}}";

  users.users.{{USERNAME}} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  system.stateVersion = "{{STATEVERSION}}";
}
