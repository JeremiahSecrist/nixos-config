{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "https://flakehub.com/f/NixOS/nixos-hardware/0.1.1715.tar.gz";
    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0.2311.3186.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-lib = {
      url = "https://flakehub.com/f/snowfallorg/lib/3.0.3.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "https://flakehub.com/f/nix-community/disko/1.3.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wg-friends = {
      url = "github:the-computer-club/automous-zones";
    };
    impermanence = {
      url = "https://flakehub.com/f/nix-community/impermanence/0.1.128.tar.gz";
    };
  };
  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      # You must provide our flake inputs to Snowfall Lib.
      inherit inputs;

      systems.modules.nixos = with inputs; [
        agenix.nixosModules.default
        jovian.nixosModules.default
        nix-index-database.nixosModules.nix-index
        impermanence.nixosModules.impermanence
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
      ];
      homes.modules = with inputs; [
        # my-input.homeModules.my-module
      ];
      # The `src` must be the root of the flake. See configuration
      # in the next section for information on how you can move your
      # Nix files to a separate directory.
      src = ./.;
    };
}
