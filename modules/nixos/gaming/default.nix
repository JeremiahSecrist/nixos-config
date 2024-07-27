{ pkgs
, lib
, config
, namespace
, ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.${namespace}.roles.gaming;
in
{
  options.${namespace}.roles.gaming = {
    enable = mkEnableOption "enables thing";
  };
  config = mkIf cfg.enable {
    programs = {
      # steam = {
      #   enable = true;
      #   package = pkgs.steam.override {
      #   # extraPkgs = pkgs:
      #     # with pkgs; [
      #     #   gamescope
      #     # ];
      # };
      # };
      gamescope.enable = true;
      gamemode = {
        enable = true;
        enableRenice = true;
      };
    };
    services.preload.enable = true;
    environment.systemPackages = with pkgs; [
      parsec-bin
      mangohud
    ];
  };
}
