{ pkgs, inputs }:
pkgs.testers.runNixOSTest {
  name = "test-name";
  nodes = {
    laptop = { config, lib, pkgs, ... }: {
      imports = with inputs.self; [
        inputs.nix-index-database.nixosModules.nix-index
        inputs.impermanence.nixosModules.impermanence
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
        inputs.nix-topology.nixosModules.default
        nixosModules.default
        nixosModules."desktops/gnome"
        nixosModules."disko/impermanence"
        nixosModules.docker
        nixosModules.gaming
        nixosModules."hardware/sound"
        nixosModules."machines/framework"
        nixosModules."networking/tailscale"
        nixosModules."networking/wg-friends"
        nixosModules."networking/yggdrasil"
        nixosModules.nix
        nixosModules."programs/nh"
        nixosModules.region
        nixosModules.tpm
        nixosModules."users/sky"
        nixosModules.vmtest
        nixosModules.yubikey
      ];
      internal = {
        roles = {
          gaming.enable = true;
        };
        programs = {
          nh.enable = true;
        };
        virtualization.docker.enable = true;
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
    };
  };
  testScript = ''
    # ...
  '';
}
