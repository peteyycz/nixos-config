{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "t14g2";

  boot.initrd.kernelModules = [ "i915" ];

  # Has to do with some nixos internals DO NOT CHANGE
  system.stateVersion = "25.11";
}
