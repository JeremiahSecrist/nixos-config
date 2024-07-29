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
}: {
  services.desktopManager.cosmic.enable = true;
  hardware.openrazer = {
    enable = true;
    users = [ "sky" ];
  };
  nix.settings = {
    substituters = [ "https://cosmic.cachix.org/" ];
    trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
  };
  users.users.sky.packages = [ pkgs.polychromatic ];
  madness.enable = true;
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];
  internal = {
    roles = {
      gaming.enable = true;
    };
    programs = {
      nh.enable = true;
    };
    virtualization.docker.enable = true;
    desktop.gnome = {
      enable = true;
      xr = true;
    };
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

  topology.self.interfaces.wg0 = {
    addresses = [ "172.16.2.42" ];
    network = "computerClub"; # Use the network we define below
    virtual = true; # doesn't change the immediate render yet, but makes the network-centric view a little more readable
    type = "wireguard"; # changes the icon
  };
  # services.wordpress.sites."localhost" = {
  #   plugins = {
  #     inherit (pkgs.internal) wpgraphql;
  #   };
  # };

  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.x86_64-linux.default
    age-plugin-yubikey
  ];

  services = {
    tailscale.enable = true;
    flatpak.enable = true;
  };
  programs = {
    ssh.extraConfig = ''
      # Don't ask for fingerprint confirmation on first connection.
      # If we know the fingerprint ahead of time, we should put it into `known_hosts` directly.
      StrictHostKeyChecking=accept-new
    '';
    zsh.enable = true;
    # noisetorch.enable = true;
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
