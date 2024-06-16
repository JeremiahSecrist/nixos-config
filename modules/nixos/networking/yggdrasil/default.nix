{ config
, lib
, namespace
, ...
}:
let
  inherit (lib) mkOption mkEnableOption mkIf mkDefault types;
  cfg = config.${namespace}.networking.yggdrasil;
in
{
  options.${namespace}.networking.yggdrasil = {
    enable = mkEnableOption "enables yggdrasil a sdwan solution";
    AllowedPublicKeys = mkOption {
      type = with types; listOf str;
      default = [ "" ];
    };
  };
  config = mkIf cfg.enable {
    services.yggdrasil = mkDefault {
      enable = true;
      openMulticastPort = true;
      persistentKeys = true;
      settings = {
        Peers = [
          "tls://ygg.yt:443"
        ];
        MulticastInterfaces = [
          {
            Regex = "w.*";
            Beacon = true;
            Listen = true;
            Port = 9001;
            Priority = 0;
          }
        ];
        AllowedPublicKeys = cfg.AllowedPublicKeys;
        IfName = "auto";
        IfMTU = 65535;
        NodeInfoPrivacy = false;
        NodeInfo = null;
      };
    };
  };
}
