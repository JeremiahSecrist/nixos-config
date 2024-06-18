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
        # nixosModules."machines/framework"
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
    };
  };
  testScript = ''
    # ...
  '';
}
