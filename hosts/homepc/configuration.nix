{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "homepc";

  boot.initrd.kernelModules = [ "amdgpu" ];

  # Has to do with some nixos internals DO NOT CHANGE
  system.stateVersion = "25.11";
}
