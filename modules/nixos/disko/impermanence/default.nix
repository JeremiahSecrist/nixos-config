{ pkgs
, lib
, config
, namespace
, ...
}:
let
  inherit (lib) mkEnableOption mkIf types mkOption;
  cfg = config.${namespace}.disko.impermanence;
in
{
  options.${namespace}.disko.impermanence = {
    enable = mkEnableOption "enables thing";
    device = mkOption {
      type = with types; str;
      default = "";
    };
    swapsize = mkOption {
      type = with types; str;
      default = "";
    };
  };
  config = mkIf cfg.enable {
    disko.devices = {
      disk.main = {
        inherit (cfg) device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            #boot = {
            # name = "boot";
            #size = "1M";
            #type = "EF02";
            #};
            esp = {
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            swap = {
              size = cfg.swapSize;
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "root_vg";
              };
            };
          };
        };
      };
      lvm_vg = {
        root_vg = {
          type = "lvm_vg";
          lvs = {
            root = {
              size = "100%FREE";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];

                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                  };

                  "/persist" = {
                    mountOptions = [ "compress=zstd" "subvol=persist" "noatime" ];
                    mountpoint = "/persist";
                  };
                  "/home" = {
                    mountOptions = [ "compress=zstd" "subvol=home" "noatime" ];
                    mountpoint = "/home";
                  };
                  "/persist/system" = { };
                  "/Games" = {
                    mountOptions = [ "defaults" "subvol=games" "nofail" ];
                    mountpoint = "/Games";
                  };

                  "/nix" = {
                    mountOptions = [ "compress=zstd" "subvol=nix" "noatime" ];
                    mountpoint = "/nix";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
