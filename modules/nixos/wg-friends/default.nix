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

  # All other arguments come from the module system.
  config
, ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  peers.asluni = inputs.wg-friends.flakeModules.asluni.wireguard.networks.asluni;
  aslib = inputs.wg-friends.lib;
in
{
  options.internal.asWireguard.enable = mkEnableOption "Enables mesh network from computerClub";
  config = mkIf config.internal.asWiregaurd.enable {

    networking.extraHosts = ''
      172.16.2.3 codex.cypress.local
      172.16.2.3 minetest.local
    '';
    networking.wireguard.interfaces = {
      # "wg0" is the network interface name. You can name the interface arbitrarily.
      wg0 = {
        # Determines the IP address and subnet of the client's end of the tunnel interface.
        ips = [ "172.16.2.42/32" ];
        listenPort = peers.asluni.listenPort; # to match firewall allowedUDPPorts (without this wg uses random port numbers)

        # Path to the private key file.
        #
        # Note: The private key can also be included inline via the privateKey option,
        # but this makes the private key world-readable; thus, using privateKeyFile is
        # recommended.
        generatePrivateKeyFile = true;
        privateKeyFile = "/var/lib/wg/wg0";
        # mapAttrsToList (name: value: name + value)
        #  { x = "a"; y = "b"; }
        # => [ "xa" "yb" ]
        peers = aslib.toNonFlakeParts peers.asluni.peers.by-name;
      };
    };
  };
}
