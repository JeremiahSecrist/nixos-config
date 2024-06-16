{ pkgs
, lib
, config
, namespace
, ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.${namespace}.users.sky;
in
{
  options.${namespace}.users.sky = {
    enable = mkEnableOption "enables thing";
    password = mkOption {
      default = null;
      type = types.str;
    };
  };
  config = mkIf cfg.enable {
    programs.zsh.enable = true;
    users.users.sky = {
      uid = 1000;
      isNormalUser = true;
      hashedPassword = cfg.password;
      shell = pkgs.zsh;
      description = "sky";
      extraGroups = [ "networkmanager" "wheel" "seat" "libvirtd" "kvm" ];
    };
  };
}
