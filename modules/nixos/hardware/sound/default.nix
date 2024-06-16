{ config
, lib
, namespace
, ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.${namespace}.hardware.sound;
in
{
  options.${namespace}.hardware.sound.enable = mkEnableOption "enables usual sound configurations";
  config = mkIf cfg.enable {
    # sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services = {
      pipewire = {
        # lowLatency = {
        # enable = true;
        # };
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };
    };
  };
}
