{
  inputs = {
    agenix = {
      url = "https://flakehub.com/f/ryantm/agenix/0.15.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    madness.url ="github:antithesishq/madness";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.637149.tar.gz";
    nixos-hardware.url = "https://flakehub.com/f/NixOS/nixos-hardware/0.1.*.tar.gz";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-lib = {
      url = "https://flakehub.com/f/snowfallorg/lib/3.*.*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "https://flakehub.com/f/Mic92/sops-nix/0.1.*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "https://flakehub.com/f/nix-community/disko/1.3.*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wg-friends = {
      url = "github:the-computer-club/automous-zones";
    };
    nix-topology.url = "github:oddlama/nix-topology";
    impermanence = {
      url = "https://flakehub.com/f/nix-community/impermanence/0.1.128.tar.gz";
    };
    wp4nix = {
      url = "git+https://git.helsinki.tools/helsinki-systems/wp4nix?ref=master";
      flake = false;
    };
  };
  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      # You must provide our flake inputs to Snowfall Lib.
      inherit inputs;
      channels-config =
        {
          allowUnfree = true;
        };
      overlays = with inputs; [
        sops-nix.overlays.default
        nix-topology.overlays.default
      ];

      systems.modules.nixos = with inputs; [
        # jovian.nixosModules.default
        madness.nixosModules.madness
        nix-index-database.nixosModules.nix-index
        impermanence.nixosModules.impermanence
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
        nix-topology.nixosModules.default
      ];
      homes.modules = with inputs; [
        # my-input.homeModules.my-module
        nix-index-database.hmModules.nix-index
      ];
      outputs-builder = channels: {
        topology = import inputs.nix-topology {
          pkgs = channels.nixpkgs;
          modules = [
            { inherit (inputs.self) nixosConfigurations; }
            ./topology.nix
          ];
        };
      };
      # The `src` must be the root of the flake. See configuration
      # in the next section for information on how you can move your
      # Nix files to a separate directory.
      src = ./.;
    };
}
