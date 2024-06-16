{ config
, lib
, pkgs
, namespace
, ...
}:
let
  cfg = config.${namespace}.yubikey;
in
{
  options.${namespace}.yubikey = {
    enable = lib.mkEnableOption "enables yubikey settings";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pcscliteWithPolkit.out
    ];
    services.pcscd = {
      enable = true;
      plugins = with pkgs; [ libykneomgr ccid ];
    };
    programs.gnupg.agent = {
      enable = true;
      # enableSSHSupport = true;
    };

    services.udev.packages = [
      pkgs.yubikey-personalization
    ];
  };
}
