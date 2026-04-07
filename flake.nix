{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      mkHost = name: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/${name}/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.peteyycz = import ./home;
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
