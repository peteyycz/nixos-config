{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "rd.systemd.show_status=auto"
    "rd.udev.log_level=3"
  ];
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.plymouth.enable = true;

  networking.networkmanager.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  time.timeZone = "Europe/Budapest";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  services.libinput.enable = true;

  programs.nix-ld.enable = true;
  programs.fish.enable = true;
  users.users.peteyycz = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    where-is-my-sddm-theme

    pavucontrol
    pasystray

    unzip

    stow
    git
    wl-clipboard

    google-chrome
    slack
    swayosd
    wev
    openssl
    tree-sitter
  ];

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs.sway.enable = true;

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
  };

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "where_is_my_sddm_theme";
      extraPackages = [ pkgs.kdePackages.qt5compat ];
    };
  };
}
