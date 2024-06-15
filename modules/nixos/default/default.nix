{ lib
, pkgs
, config
, ...
}:
let
  inherit (lib) mkIf mkOption types;
in
{
  options.internal.list = mkOption {
    type = with types; listOf str;
    default = [ ];
  };
  config = mkIf (builtins.elm "default" config.internal.list) {
    systemd.services.bctl = mkIf builtins.elm "laptop" config.internal.list {
      enable = config.local.impermanence.enable;
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = ''${pkgs.brightnessctl}/bin/brightnessctl set 10%'';
      };
    };
  };
}
