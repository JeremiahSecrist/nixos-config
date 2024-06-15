{ pkgs
, lib
, config
, ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.nix;
in
{
  options.internal.nix = {
    enable = mkEnableOption "enables thing";
  };
  config = mkIf cfg.enable { };
}
