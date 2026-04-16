{ config, pkgs, lib, ... }:

let
  colorsLib = import ./colors.nix { inherit lib; };
  colors = colorsLib.palette;
  inherit (colorsLib) c rgba;

  open-runde = pkgs.stdenvNoCC.mkDerivation {
    pname = "open-runde";
    version = "1.0.1";
    src = pkgs.fetchzip {
      url = "https://github.com/lauridskern/open-runde/releases/download/v1.0.1/OpenRunde-1.0.1.zip";
      sha256 = "1nv2124hpkmvn5byk9xnm3vq7nh0ivlld0nndmm5dvw142mf222x";
      stripRoot = false;
    };
    installPhase = ''
      install -Dm644 -t $out/share/fonts/opentype "$src"/OpenRunde-1.0.1/desktop/*.otf
    '';
    meta = {
      description = "A soft, rounded variant of Inter";
      homepage = "https://github.com/lauridskern/open-runde";
      license = lib.licenses.ofl;
    };
  };
in
{
  home.packages = with pkgs; [
    libnotify
    slurp
    wf-recorder
    jq
    inter
    open-runde
    sway-contrib.grimshot
    (lib.lowPrio papirus-icon-theme)
  ];

  programs.rofi = {
    enable = true;
    font = "Open Runde 13";
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      display-drun = "";
      display-run = "";
      display-window = "";
      display-combi = "";
      drun-display-format = "{name}";
      kb-remove-char-forward = "Delete";
      kb-remove-to-sol = "";
      kb-page-prev = "Control+u";
      kb-page-next = "Control+d";
      kb-delete-entry = "";
    };
    theme = let inherit (config.lib.formats.rasi) mkLiteral; in {
      "*" = {
        bg = mkLiteral colors.bg;
        bg1 = mkLiteral colors.bg1;
        bg2 = mkLiteral colors.bg2;
        gray = mkLiteral colors.gray;
        fg3 = mkLiteral colors.fg3;
        fg = mkLiteral colors.fg;
        red = mkLiteral colors.red;
        yellow = mkLiteral colors.yellow;
        blue = mkLiteral colors.blue;
        purple = mkLiteral colors.purple;
        aqua = mkLiteral colors.aqua;
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
        highlight = mkLiteral "bold ${colors.purple}";
      };
      window = {
        width = mkLiteral "560px";
        background-color = mkLiteral (rgba colors.bg 0.75);
        border = mkLiteral "0";
        border-radius = mkLiteral "14px";
      };
      mainbox = {
        padding = mkLiteral "12px";
      };
      inputbar = {
        padding = mkLiteral "10px 16px";
        margin = mkLiteral "0 0 12px 0";
        background-color = mkLiteral "@bg1";
        border-radius = mkLiteral "9999px";
        children = map mkLiteral [ "prompt" "textbox-prompt-colon" "entry" ];
      };
      prompt = {
        text-color = mkLiteral "@purple";
      };
      "textbox-prompt-colon" = {
        expand = false;
        str = " ";
      };
      entry = {
        placeholder = "Search...";
        placeholder-color = mkLiteral "@gray";
        text-color = mkLiteral "@fg";
      };
      listview = {
        lines = 8;
        columns = 1;
        fixed-height = true;
        spacing = mkLiteral "4px";
      };
      element = {
        padding = mkLiteral "8px 14px";
        border-radius = mkLiteral "10px";
        spacing = mkLiteral "10px";
      };
      "element selected" = {
        background-color = mkLiteral "@bg2";
        text-color = mkLiteral "@purple";
        border-radius = mkLiteral "10px";
      };
      element-icon = {
        size = mkLiteral "24px";
        margin = mkLiteral "0 10px 0 0";
      };
      element-text = {
        vertical-align = mkLiteral "0.5";
      };
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      ignore-empty-password = true;
      show-failed-attempts = true;

      color = c colors.bg;

      ring-color = c colors.bg1;
      ring-clear-color = c colors.gray;
      ring-caps-lock-color = c colors.yellow;
      ring-ver-color = c colors.blueDark;
      ring-wrong-color = c colors.red;

      key-hl-color = c colors.blueDark;
      bs-hl-color = c colors.gray;
      caps-lock-key-hl-color = c colors.yellow;
      caps-lock-bs-hl-color = c colors.red;

      inside-color = c colors.bg;
      inside-clear-color = c colors.bg;
      inside-caps-lock-color = c colors.bg;
      inside-ver-color = c colors.bg;
      inside-wrong-color = c colors.bg;

      line-color = c colors.bg;
      line-clear-color = c colors.bg;
      line-caps-lock-color = c colors.bg;
      line-ver-color = c colors.bg;
      line-wrong-color = c colors.bg;

      separator-color = c colors.bg1;

      text-color = c colors.fg;
      text-clear-color = c colors.gray;
      text-caps-lock-color = c colors.yellow;
      text-ver-color = c colors.blueDark;
      text-wrong-color = c colors.red;

      layout-text-color = c colors.fg3;

      indicator-radius = 60;
      indicator-thickness = 20;
    };
  };

  services.swayidle = {
    enable = true;
    events = [
      { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
    ];
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "VictorMono Nerd Font Mono:style=Medium:size=14";
        pad = "7x7";
        selection-target = "clipboard";
      };
      url = {
        launch = "xdg-open \${url}";
      };
      key-bindings = {
        show-urls-launch = "Control+Shift+o";
      };
      colors-dark = {
        alpha = "0.95";
        background = c colors.bg;
        foreground = c colors.fg;
        regular0 = c colors.bg;
        regular1 = c colors.redDark;
        regular2 = c colors.greenDark;
        regular3 = c colors.yellowDark;
        regular4 = c colors.blueDark;
        regular5 = c colors.purpleDark;
        regular6 = c colors.aquaDark;
        regular7 = c colors.fg4;
        bright0 = c colors.gray;
        bright1 = c colors.red;
        bright2 = c colors.green;
        bright3 = c colors.yellow;
        bright4 = c colors.blue;
        bright5 = c colors.purple;
        bright6 = c colors.aqua;
        bright7 = c colors.fg;
      };
    };
  };
}
