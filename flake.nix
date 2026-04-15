{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    peon-ping.url = "github:PeonPing/peon-ping";
  };

  outputs = { self, nixpkgs, home-manager, peon-ping, ... }:
    let
      system = "x86_64-linux";
      mkHost = name: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/${name}/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.peteyycz = import ./home;
            home-manager.sharedModules = [
              peon-ping.homeManagerModules.default
              {
                programs.peon-ping.package = peon-ping.packages.${system}.default;
                home.packages = [ peon-ping.packages.${system}.default ];
              }
            ];
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        t440p = mkHost "t440p";
        t14g2 = mkHost "t14g2";
      };
    };
}
