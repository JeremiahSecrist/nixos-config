{ config
, lib
, pkgs
, modulesPath
, inputs
, namespace
, ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.${namespace}.machines.framework;
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  options.${namespace}.machines.framework.enable = mkEnableOption "used for framework laptop";
  config = mkIf cfg.enable
    {
      zramSwap.enable = true;
      networking = {
        networkmanager.wifi.backend = "iwd";
        wireless.iwd.enable = true;
        useDHCP = lib.mkDefault true;
      };
      boot = {
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
        tmp.cleanOnBoot = true;
        kernel.sysctl = {
          "net.core.default_qdisc" = "fq";
          "net.ipv4.tcp_congestion_control" = "bbr";
        };
        # kernelPackages = pkgs.linuxPackages_xanmod;
        initrd = {
          kernelModules = [
            "dm-snapshot"
            "dm_mirror"
          ];
          availableKernelModules = [
            "nvme"
            "xhci_pci"
            "thunderbolt"
            "usbhid"
            "uas"
            "sd_mod"
          ];
        };
        kernelModules = [
          "kvm-amd"
        ];

        kernelParams = [
          "amd_iommu=on"
          "iommu=pt"
        ];
      };

      # enable proper mouse usage on xorg.
      services = {
        xserver.videoDrivers = [ "amdgpu" ];
        libinput.enable = true;
        fstrim.enable = true;
        system76-scheduler.settings.cfsProfiles.enable = true;
        fwupd.enable = true;
        hardware.bolt.enable = true;
      };
      hardware = {
        enableAllFirmware = true;
        bluetooth.enable = true;
        opengl = {
          enable = true;
          driSupport = true;
          driSupport32Bit = true;
          extraPackages = with pkgs; [
            intel-media-driver # LIBVA_DRIVER_NAME=iHD
            vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
            vaapiVdpau
            libvdpau-va-gl
          ];
        };
      };
      # networking.interfaces.eht0.useDHCP = lib.mkForce true;
      # nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = true;

      systemd.services.bctl = {
        enable = config.internal.disko.impermanence.enable;
        wantedBy = [ "multi-user.target" ];
        after = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = ''${pkgs.brightnessctl}/bin/brightnessctl set 10%'';
        };
      };
    };
}
