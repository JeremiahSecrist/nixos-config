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
{
  internal = {
    roles = {
      gaming.enable = true;
    };
    desktop.gnome.enable = true;
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


  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.x86_64-linux.default
    age-plugin-yubikey
  ];

  services.xserver.enable = true;
  services.switcherooControl.enable = lib.mkIf (builtins.elem "hello" config.system.nixos.tags) true;

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



  system.stateVersion = "23.11";
}

