{ pkgs
, lib
, config
, namespace
, ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.${namespace}.virtualization.docker;
in
{
  options.${namespace}.virtualization.docker = {
    enable = mkEnableOption "enables thing";
  };
  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;
    users.users.sky.extraGroups = [ "docker" ];
  };
}
