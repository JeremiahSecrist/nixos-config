{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib
, # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs
, # You also have access to your flake's inputs.
  inputs
, # Additional metadata is provided by Snowfall Lib.
  namespace
, # The namespace used for your flake, defaulting to "internal" if not set.
  system
, # The system architecture for this host (eg. `x86_64-linux`).
  target
, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format
, # A normalized name for the system target (eg. `iso`).
  virtual
, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems
, # An attribute map of your defined hosts.

  # All other arguments come from the system system.
  config
, ...
}:
let
  module = "";
in
{
  # disabledModules = lib.mkForce [ "${modulePath}/nixos/modules/services/databases/etcd.nix" ];
  # assertions = [
  #   {
  #     assertion = (builtins.elem "services/misc/etcd.nix" self.disabledModules);
  #     message = "Can't disable etcd.nix";
  #   }
  # ];
  # imports = [
  #   (import ../../modules/nixos/disks/impermanence.nix {
  #     device = "/dev/nvme0n1";
  #     swapSize = "8G";
  #   })
  #   ./wiregaurd.nix
  # ];
  internal = {
    networking.asWireguard.enable = true;
    disko.impermanence = {
      enable = true;
      swapsize = "8G";
      device = "/dev/nvme0n1";
    };
    tmp.enable = true;
    yubikey.enable = true;
    machines.framework.enable = true;
    hardware = {
      sound.enable = true;
    };
    region = { enable = true; };
    nix = {
      enable = true;
      isBuilder = false;
      allowUnfree = true;
    };
    users.sky = {
      enable = true;
      password = "$y$j9T$5FxOeqdICm5REo/NMm9pM1$Tt.kY2OP05CLo4y1nOjxx/e4ObzsQILZuJRu4xQlrM/";
    };
  };
  virtualisation.docker.enable = true;
  users.users.sky.extraGroups = [ "docker" ];
  systemd.services.bctl = {
    enable = config.internal.disko.impermanence.enable;
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.brightnessctl}/bin/brightnessctl set 10%'';
    };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  system.nixos.tags = [ "zramSwap" ];

  zramSwap.enable = lib.mkIf (builtins.elem "zramSwap" config.system.nixos.tags) true;
  # services.teamviewer.enable = true;
  # services.rustdesk.enable = true;
  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff \
           /run/current-system "$systemConfig"
    '';
  };
  environment.systemPackages = with pkgs; [
    parsec-bin
    inputs.agenix.packages.x86_64-linux.default
    age-plugin-yubikey
    mangohud
  ];
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
    "kernel.perf_event_paranoid" = 1;
  };
  services.xserver.videoDrivers = [ "amdgpu" ];
  # environment.sessionVariables = {
  #   MESA_VK_DEVICE_SELECT_FORCE_DEFAULT_DEVICE = "${card}";
  #   MESA_VK_WSI_PRESENT_MODE = "immediate";
  #   KWIN_DRM_DEVICES = "/dev/dri/card${card}";
  #   KMSDEVICE = "/dev/dri/card${card}";
  # };
  # # services.ollama = {
  # #   enable = true;
  # #   acceleration = "rocm";
  # #   environmentVariables = {
  # #     HSA_OVERRIDE_GFX_VERSION="10.3.0";
  # #   };
  # # };
  #  services.udev.extraRules = ''
  #       # ensure all cards don't get seat and master-of-seat tags
  #       SUBSYSTEM=="drm", KERNEL=="card1", TAG-="seat", TAG-="master-of-seat", ENV{ID_FOR_SEAT}="", ENV{ID_PATH}=""
  #       # adds seat, master-of-seat and mutter-device-preferred-primary tag for desired card
  #       # TODO: are there any other tags here used by other compositors?
  #       SUBSYSTEM=="drm", KERNEL=="card${card}", TAG+="seat", TAG+="master-of-seat", TAG+="mutter-device-preferred-primary"
  #     '';
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.switcherooControl.enable = lib.mkIf (builtins.elem "hello" config.system.nixos.tags) true;
  # Enable the Budgie Desktop environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;
  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
      gedit # text editor
    ])
    ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gnome-terminal
      epiphany # web browser
      geary # email reader
      evince # document viewer
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ]);
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  programs.gamescope.enable = true;
  # services.xserver.displayManager.defaultSession = "plasma";
  programs.command-not-found.enable = false;
  programs.nix-index-database.comma.enable = true;
  services.tailscale.enable = true;
  # Configure keymap in X11
  services.xserver = {
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  hardware.enableAllFirmware = true;

  services = {
    # miniupnpd = {
    #   enable = true;
    #   externalInterface = [
    #     "eth0"
    #     "wlan0"
    #   ];
    #   natpmp = true;
    # };
    flatpak.enable = true;
    preload.enable = true;
  };
  programs = {
    ssh.extraConfig = ''
      # Don't ask for fingerprint confirmation on first connection.
      # If we know the fingerprint ahead of time, we should put it into `known_hosts` directly.
      StrictHostKeyChecking=accept-new
    '';
    zsh.enable = true;
    noisetorch.enable = true;
    # steam = {
    #   enable = true;
    #   package = pkgs.steam.override {
    #   # extraPkgs = pkgs:
    #     # with pkgs; [
    #     #   gamescope
    #     # ];
    # };
    # };
    gamemode = {
      enable = true;
      enableRenice = true;
    };
  };
  networking = {
    # dhcpcd.enable = false;
    # nameservers = ["1.1.1.1" "1.0.0.1"];
    networkmanager = {
      enable = true;
      insertNameservers = [ "1.1.1.1" "1.0.0.1" ];
    };
    hostName = "lappy";
    firewall = {
      enable = false;
      # checkReversePath = false;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  nix = {
    registry = {
      self.flake = inputs.self;
      nixpkgs.flake = inputs.nixpkgs;
    };
  };

  system.stateVersion = "23.11";
}

