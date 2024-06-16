{ pkgs
, lib
, config
, namespace
, ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.${namespace}.programs.nh;
in
{
  options.${namespace}.programs.nh = {
    enable = mkEnableOption "enables thing";
  };
  config = mkIf cfg.enable {
    programs.nh = {
      flake = "/home/sky/Documents/code/nixos-config";
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep 5 --keep-since 3d";
      };
      
    };
   };
}