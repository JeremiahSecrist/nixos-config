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
    environment.etc."machine-id" = {
      text = "87f2201d1aa14509b92aba0d5e67be96";
      mode = "0644";
    };

    boot.initrd.postDeviceCommands = lib.mkAfter ''
      mkdir /btrfs_tmp
      mount /dev/root_vg/root /btrfs_tmp
      if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi
      delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
          delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
      }
      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
      done
      btrfs subvolume create /btrfs_tmp/root
      umount /btrfs_tmp
    '';

    fileSystems."/persist".neededForBoot = true;
    environment.persistence."/persist/system" = {
      hideMounts = true;
      directories = [
        "/root"
        "/etc/nixos"
        "/var/log"
        # "/home"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/lib/misc"
        "/var/lib/microvms"
        "/var/lib/wg"
        "/etc/NetworkManager/system-connections"
        "/var/lib/iwd"
        "/var/lib/flatpak"
        {
          directory = "/var/lib/colord";
          user = "colord";
          group = "colord";
          mode = "u=rwx,g=rx,o=";
        }
        # {
        #   directory = "/sys/class/backlight/amdgpu_bl0";
        #   user = "root";
        #   group = "root";
        #   mode = "u=rwx,g=rwx,o=rwx";
        # }
      ];
      files = [
        {
          file = "/var/keys/secret_file";
          parentDirectory = { mode = "u=rwx,g=,o="; };
        }
        # "/sys/class/backlight/amdgpu_bl0/brightness"
        # "/etc/shadow"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
      ];
    };
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
