{ config
, lib
, pkgs
, modulesPath
, inputs
, ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.machines.framework;
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  options.internal.machines.framework.enable = mkEnableOption "used for framework laptop";
  config = mkIf cfg.enable {
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
      xserver.libinput.enable = true;
      fstrim.enable = true;
      system76-scheduler.settings.cfsProfiles.enable = true;
      fwupd.enable = true;
      hardware.bolt.enable = true;
    };
    hardware = {
      bluetooth.enable = true;
      opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };
    };
    # networking.interfaces.eht0.useDHCP = lib.mkForce true;
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = true;
  };
}
