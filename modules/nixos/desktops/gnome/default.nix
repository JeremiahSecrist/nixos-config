{ config
, pkgs
, lib
, namespace
, ...
}:
let
  # opt = options.custom.desktop.gnome;
  cfg = config.${namespace}.desktop.gnome;
in
{
  options.${namespace}.desktop.gnome = {
    enable = lib.mkEnableOption "This enables gnome desktop";
    xr = lib.mkEnableOption "enables xr driver";
  };
  config = lib.mkIf cfg.enable {
    services = {
      gnome.gnome-keyring.enable = true;
      displayManager.defaultSession = lib.mkForce "gnome";
      libinput.enable = true;
      xserver = {
        enable = true;
        xkb = {
          variant = "";
          layout = "us";
        };
        displayManager = {
          gdm = {
            enable = true;
            wayland = true;
          };
          # desktopSession = "gnome";
        };
        desktopManager = {
          gnome.enable = lib.mkDefault true;
        };
      };
      udev.packages = [ pkgs.yubikey-personalization pkgs.gnome3.gnome-settings-daemon ];
    };
    services.fprintd.enable = false;

    # # exclude the following packages from the default installation
    # environment.gnome.excludePackages =
    #   (with pkgs; [
    #     gnome-photos
    #     gnome-tour
    #     gedit # text editor
    #   ])
    #   ++ (with pkgs.gnome; [
    #     # cheese # webcam tool
    #     gnome-music
    #     # gnome-terminal
    #     # epiphany # web browser
    #     # geary # email reader
    #     evince # document viewer
    #     gnome-characters
    #     totem # video player
    #     tali # poker game
    #     iagno # go game
    #     hitori # sudoku game
    #     atomix # puzzle game
    #   ]);

    programs = {
      xwayland.enable = lib.mkDefault true;
    };
    xdg.portal = { enable = lib.mkDefault true; };
  };
}
