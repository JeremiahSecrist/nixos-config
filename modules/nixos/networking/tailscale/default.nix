{ config
, lib
, namespace
, ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.${namespace}.networking.tailscale;
in
{
  options.${namespace}.networking.tailscale.enable = mkEnableOption "";
  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };
  };
}
