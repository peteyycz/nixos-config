{ config, lib, pkgs, isLaptop, ... }:

let
  wallpaper = pkgs.fetchurl {
    url = "https://w.wallhaven.cc/full/9o/wallhaven-9o8k9w.jpg";
    sha256 = "0gsvramfqdfcgjclqndwnkcqa5a1z6fnnq0jrmz3k4icc4sqigyy";
  };

  pixie-sddm-theme = pkgs.stdenvNoCC.mkDerivation {
    pname = "pixie-sddm";
    version = "3.0";
    src = pkgs.fetchFromGitHub {
      owner = "xCaptaiN09";
      repo = "pixie-sddm";
      rev = "6f2e77c269c43a455bd81c3ecac1fff796c0253c";
      hash = "sha256-NkjWP/y3kLRjYM0Wr3l7ndbMx3XYxQFXy07C28vrUSU=";
    };
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/sddm/themes/pixie
      cp -r assets components Main.qml metadata.desktop theme.conf LICENSE \
        $out/share/sddm/themes/pixie/
      cp ${wallpaper} $out/share/sddm/themes/pixie/assets/background.jpg
      runHook postInstall
    '';
  };
in
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
    config.hyprland = {
      default = lib.mkForce [ "hyprland" "gtk" ];
      "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
    };
  };

  time.timeZone = "Europe/Budapest";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    wireplumber.extraConfig = lib.mkIf isLaptop {
      "51-hide-hdmi-audio" = {
        "monitor.alsa.rules" = [{
          matches = [{ "node.name" = "~alsa_output\\..*HDMI.*"; }];
          actions.update-props."node.disabled" = true;
        }];
      };
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.tumbler.enable = true;
  services.upower.enable = true;

  services.libinput.enable = true;

  programs.nix-ld.enable = true;
  programs.fish.enable = true;
  users.users.peteyycz = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.fish;
  };

  virtualisation.docker.enable = true;

  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = [ pixie-sddm-theme ] ++ (with pkgs; [

    pavucontrol

    unzip

    stow
    git
    wl-clipboard

    google-chrome
    slack
    nautilus
    nautilus-open-any-terminal
    file-roller
    sushi
    swayosd
    wev
    openssl
    tree-sitter
  ]);

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "peteyycz" ];
  };
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
  };

  fonts.packages = with pkgs.nerd-fonts; [ symbols-only jetbrains-mono ];

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "pixie";
      extraPackages = with pkgs.kdePackages; [
        qt5compat
        qtdeclarative
        qtsvg
      ];
    };
  };
}
