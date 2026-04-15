{ config, pkgs, lib, ... }:

let
  # Gruvbox Dark colors
  colors = {
    bg = "#282828";
    bgHard = "#1d2021";
    bg1 = "#3c3836";
    bg2 = "#504945";
    bg3 = "#665c54";
    gray = "#928374";
    fg3 = "#bdae93";
    fg4 = "#a89984";
    fg = "#ebdbb2";
    # Normal colors
    red = "#fb4934";
    redDark = "#cc241d";
    green = "#b8bb26";
    greenDark = "#98971a";
    yellow = "#fabd2f";
    yellowDark = "#d79921";
    orange = "#fe8019";
    blue = "#83a598";
    blueDark = "#458588";
    purple = "#d3869b";
    purpleDark = "#b16286";
    aqua = "#8ec07c";
    aquaDark = "#689d6a";
  };

  # Strip # from color for configs that don't want it
  c = color: lib.removePrefix "#" color;

  # Convert a "#RRGGBB" color to a GTK/CSS rgba() string with the given alpha
  rgba = color: alpha:
    let
      hex = lib.removePrefix "#" color;
      hexDigit = {
        "0" = 0; "1" = 1; "2" = 2; "3" = 3; "4" = 4;
        "5" = 5; "6" = 6; "7" = 7; "8" = 8; "9" = 9;
        "a" = 10; "b" = 11; "c" = 12; "d" = 13; "e" = 14; "f" = 15;
        "A" = 10; "B" = 11; "C" = 12; "D" = 13; "E" = 14; "F" = 15;
      };
      byte = offset:
        hexDigit.${builtins.substring offset 1 hex} * 16
        + hexDigit.${builtins.substring (offset + 1) 1 hex};
    in
      "rgba(${toString (byte 0)}, ${toString (byte 2)}, ${toString (byte 4)}, ${toString alpha})";

  modifier = "Mod4";
  terminal = "foot";
  menu = "rofi -terminal '${terminal}' -show drun";

  # Workspace names with icons
  ws1 = "1: 󰆍";
  ws2 = "2: 󰊯";
  ws3 = "3: 󰓓";
  ws4 = "4: 󰊗";
  ws9 = "9: 󰒱";

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
    # Sway and Wayland essentials
    libnotify
    slurp
    wf-recorder
    jq  # Used by tmux-rofi script
    inter
    open-runde
    sway-contrib.grimshot
    (lib.lowPrio papirus-icon-theme)  # Used by rofi icon-theme; lowPrio avoids breeze-dark collision with gruvbox-plus-icons
  ];

  wayland.windowManager.sway = {
    enable = true;
    package = null;
    systemd.enable = true;
    checkConfig = false;  # Background uses $HOME which isn't available in sandbox

    config = {
      inherit modifier terminal menu;

      fonts = {
        names = [ "Open Runde" ];
        size = 11.0;
      };

      colors = {
        focused = {
          border = colors.bgHard;
          background = colors.bgHard;
          text = colors.fg;
          indicator = colors.orange;
          childBorder = colors.bgHard;
        };
        focusedInactive = {
          border = colors.bg;
          background = colors.bg;
          text = colors.fg3;
          indicator = colors.bg;
          childBorder = colors.bg;
        };
        unfocused = {
          border = colors.bg;
          background = colors.bg;
          text = colors.gray;
          indicator = colors.bg;
          childBorder = colors.bg;
        };
        urgent = {
          border = colors.red;
          background = colors.red;
          text = colors.bg;
          indicator = colors.red;
          childBorder = colors.red;
        };
      };

      output = {
        "*" = {
          bg = "$HOME/.local/share/backgrounds/default.jpg fill";
          scale = "1";
        };
      };

      input = {
        "2:7:SynPS/2_Synaptics_TouchPad" = {
          dwt = "enabled";
          tap = "enabled";
          natural_scroll = "enabled";
          middle_emulation = "enabled";
          accel_profile = "adaptive";
          pointer_accel = "0.5";
        };
        "type:keyboard" = {
          xkb_layout = "us,hu";
          xkb_variant = ",qwerty";
          xkb_options = "ctrl:nocaps,grp:alt_shift_toggle";
        };
      };

      floating.modifier = modifier;

      keybindings = lib.mkOptionDefault {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+q" = "kill";
        "${modifier}+d" = "exec ${menu}";

        # Volume / mic
        "XF86AudioMute" = "exec swayosd-client --output-volume mute-toggle";
        "XF86AudioLowerVolume" = "exec swayosd-client --output-volume lower";
        "XF86AudioRaiseVolume" = "exec swayosd-client --output-volume raise";
        "XF86AudioMicMute" = "exec swayosd-client --input-volume mute-toggle";
        "${modifier}+Escape" = "exec loginctl lock-session";
        "${modifier}+Shift+c" = "reload";
        "${modifier}+Shift+e" = ''exec "echo -e 'Lock\nLogout\nSuspend\nShutdown\nRestart' | rofi -dmenu -p 'Power' -i | xargs -I {} sh -c 'case {} in Lock) loginctl lock-session;; Logout) swaymsg exit;; Suspend) systemctl suspend;; Shutdown) systemctl poweroff;; Restart) systemctl reboot;; esac'"'';

        # Focus
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";
        "${modifier}+Left" = "focus left";
        "${modifier}+Down" = "focus down";
        "${modifier}+Up" = "focus up";
        "${modifier}+Right" = "focus right";

        # Move
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";
        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Right" = "move right";

        # Workspaces
        "${modifier}+1" = "workspace ${ws1}";
        "${modifier}+2" = "workspace ${ws2}";
        "${modifier}+3" = "workspace ${ws3}";
        "${modifier}+4" = "workspace ${ws4}";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace ${ws9}";
        "${modifier}+0" = "workspace number 10";

        # Move to workspace
        "${modifier}+Shift+1" = "move container to workspace ${ws1}";
        "${modifier}+Shift+2" = "move container to workspace ${ws2}";
        "${modifier}+Shift+3" = "move container to workspace ${ws3}";
        "${modifier}+Shift+4" = "move container to workspace ${ws4}";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace ${ws9}";
        "${modifier}+Shift+0" = "move container to workspace number 10";

        # Layout
        "${modifier}+b" = "splith";
        "${modifier}+v" = "splitv";
        "${modifier}+s" = "layout stacking";
        "${modifier}+w" = "exec tmux-rofi";
        "${modifier}+e" = "layout toggle split";
        "${modifier}+f" = "fullscreen";
        "${modifier}+Shift+f" = "floating toggle";
        "${modifier}+space" = "focus mode_toggle";
        "${modifier}+a" = "focus parent";

        # Scratchpad
        "${modifier}+Shift+minus" = "move scratchpad";
        "${modifier}+minus" = "scratchpad show";

        # Scripts
        "${modifier}+r" = ''exec "find $HOME/Code/src/github.com/peteyycz/scripts -maxdepth 1 -name '*.sh' -printf '%f\n' | sed 's/\.sh$//' | rofi -dmenu -p 'Scripts' -i | xargs -I {} sh -c '$HOME/Code/src/github.com/peteyycz/scripts/{}.sh'"'';

        # Screenshots
        "Print" = "exec grimshot save output";
        "Alt+Print" = "exec grimshot save active";
        "Ctrl+Print" = "exec grimshot copy anything";
        "${modifier}+Print" = ''exec bash -c 'region=$(slurp) && wf-recorder -g "$region" -f ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4' '';
        "${modifier}+Shift+Print" = "exec killall -s SIGINT wf-recorder";
      };

      assigns = {
        "${ws2}" = [{ app_id = "google-chrome"; }];
        "${ws3}" = [{ class = "^Steam$"; }];
        "${ws4}" = [{ class = "^steam_app"; }];
        "${ws9}" = [{ app_id = "com.slack.Slack"; }];
      };

      window.commands = [
        { criteria = { class = "^Steam$"; }; command = "floating enable"; }
        { criteria = { class = "^Steam$"; title = "^Steam$"; }; command = "floating disable"; }
        { criteria = { class = "^steam_app"; }; command = "inhibit_idle focus"; }
        { criteria = { class = ".*"; }; command = "inhibit_idle fullscreen"; }
        { criteria = { app_id = "^org\\.gnome\\.Nautilus$"; }; command = "floating enable"; }
        { criteria = { app_id = "^imv$"; }; command = "floating enable"; }
        { criteria = { app_id = "^mpv$"; }; command = "floating enable"; }
        { criteria = { app_id = "^org\\.gnome\\.NautilusPreviewer$"; }; command = "floating enable"; }
      ];

      startup = [
        { command = "test -x $HOME/Code/src/github.com/peteyycz/scripts/@peteyycz:dev-start.sh && $HOME/Code/src/github.com/peteyycz/scripts/@peteyycz:dev-start.sh"; }
        { command = "sleep 0.5 && swaymsg 'workspace ${ws1}; exec ${terminal}'"; }
        { command = "1password --silent"; }
        { command = "swayosd-server"; }
        { command = "blueman-applet"; }
        { command = "pasystray"; }
      ];

      bars = [{
        command = "waybar";
      }];
    };

    extraConfig = ''
      titlebar_padding 14 8
      gaps inner 8
      gaps outer 4

      default_border pixel 0
      default_floating_border pixel 0

      corner_radius 12

      shadows enable
      shadows_on_csd enable
      shadow_blur_radius 20
      shadow_color #0000007F
      shadow_offset 0 5

      blur enable
      blur_passes 3
      blur_radius 5
      blur_saturation 1.1

      default_dim_inactive 0.15
      dim_inactive_colors.unfocused #000000FF
      dim_inactive_colors.urgent #900000FF

      layer_effects "waybar" blur enable; blur_ignore_transparent enable
      layer_effects "rofi" blur enable; blur_ignore_transparent enable
      layer_effects "notifications" blur enable; blur_ignore_transparent enable
    '';
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "keyboard";
        width = 350;
        height = "(0, 300)";
        origin = "top-right";
        offset = "(10, 10)";
        scale = 0;
        notification_limit = 5;

        progress_bar = true;
        progress_bar_height = 12;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        progress_bar_corner_radius = 8;
        progress_bar_corners = "all";

        icon_corner_radius = 8;
        icon_corners = "all";

        indicate_hidden = true;
        separator_height = 2;
        padding = 20;
        horizontal_padding = 20;
        text_icon_padding = 16;
        frame_width = 0;
        frame_color = colors.bg1;
        gap_size = 8;
        separator_color = "frame";
        sort = true;

        font = "Open Runde 11";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;

        enable_recursive_icon_lookup = true;
        icon_theme = "Adwaita";
        icon_position = "left";
        min_icon_size = 32;
        max_icon_size = 64;

        sticky_history = true;
        history_length = 20;

        dmenu = "/usr/bin/dmenu -p dunst:";
        browser = "/usr/bin/xdg-open";
        always_run_script = true;
        corner_radius = 12;
        corners = "all";
        ignore_dbusclose = false;
        force_xwayland = false;
        force_xinerama = false;

        mouse_left_click = "do_action, close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };

      experimental = {
        per_monitor_dpi = false;
      };

      urgency_low = {
        background = colors.bgHard;
        foreground = colors.gray;
        frame_color = colors.bg1;
        timeout = 5;
        default_icon = "dialog-information";
      };

      urgency_normal = {
        background = colors.bgHard;
        foreground = colors.fg;
        frame_color = colors.purple;
        timeout = 10;
        override_pause_level = 30;
        default_icon = "dialog-information";
      };

      urgency_critical = {
        background = colors.bgHard;
        foreground = colors.fg;
        frame_color = colors.red;
        timeout = 0;
        override_pause_level = 60;
        default_icon = "dialog-warning";
      };
    };
  };

  programs.rofi = {
    enable = true;
    font = "Open Runde 16";
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
        width = mkLiteral "680px";
        background-color = mkLiteral "@bg";
        border = mkLiteral "0";
        border-radius = mkLiteral "16px";
      };
      mainbox = {
        padding = mkLiteral "16px";
      };
      inputbar = {
        padding = mkLiteral "14px 20px";
        margin = mkLiteral "0 0 16px 0";
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
        padding = mkLiteral "10px 16px";
        border-radius = mkLiteral "12px";
        spacing = mkLiteral "12px";
      };
      "element selected" = {
        background-color = mkLiteral "@bg2";
        text-color = mkLiteral "@purple";
        border-radius = mkLiteral "12px";
      };
      element-icon = {
        size = mkLiteral "32px";
        margin = mkLiteral "0 12px 0 0";
      };
      element-text = {
        vertical-align = mkLiteral "0.5";
      };
    };
  };

  programs.waybar = {
    enable = true;
    settings = [{
      layer = "top";
      position = "top";
      margin-top = 10;
      margin-left = 8;
      margin-right = 8;
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "clock" ];
      modules-right = [ "custom/recording" "cpu" "memory" "battery" "network" "sway/language" "custom/dotfiles" "tray" ];

      "custom/dotfiles" = {
        exec = ''cd ~/Code/src/github.com/peteyycz/nixos-config && if [ -n "$(git status --porcelain)" ]; then echo '{"text": "~/.", "tooltip": "Config has uncommitted changes", "class": "dirty"}'; else echo '{}'; fi'';
        return-type = "json";
        interval = 30;
        on-click = "foot --working-directory=$HOME/Code/src/github.com/peteyycz/nixos-config $SHELL -c 'git status; exec $SHELL'";
      };

      "custom/recording" = {
        exec = ''if pgrep -x wf-recorder > /dev/null; then echo '{"text": "REC", "tooltip": "Click to stop recording", "class": "active"}'; else echo '{}'; fi'';
        return-type = "json";
        interval = 1;
        on-click = "killall -s SIGINT wf-recorder";
      };

      "sway/workspaces" = {
        disable-scroll = true;
      };

      "sway/mode" = {
        format = "{}";
      };

      clock = {
        format = "{:%I:%M %p}";
        tooltip-format = "{:%A, %B %d %Y}";
      };

      cpu = {
        format = "󰻠 {usage}%";
        interval = 5;
        states = { warning = 70; critical = 90; };
      };

      memory = {
        format = "󰍛 {percentage}%";
        interval = 10;
        states = { warning = 70; critical = 90; };
      };

      battery = {
        states = { warning = 30; critical = 15; };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󰚥 {capacity}%";
        format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        tooltip-format = "{timeTo}\n{power}W";
      };

      "sway/language" = {
        format = "<span font_family='VictorMono Nerd Font Propo' rise='-1500'>󰌌</span> {short}";
      };

      network = {
        format-wifi = "<span font_family='VictorMono Nerd Font Propo' rise='-1500'>󰖩</span> {essid}";
        format-ethernet = "<span font_family='VictorMono Nerd Font Propo' rise='-1500'>󰈀</span> {ifname}";
        format-disconnected = "<span font_family='VictorMono Nerd Font Propo' rise='-1500'>󰖪</span> offline";
        tooltip-format-wifi = "{essid} ({signalStrength}%)\n{ipaddr}";
        tooltip-format-ethernet = "{ifname}\n{ipaddr}";
        on-click = "foot -e nmtui";
      };

      tray = {
        icon-size = 16;
        spacing = 8;
      };
    }];
    style = ''
      * {
        font-family: "Open Runde";
        font-size: 12pt;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      #clock {
        font-weight: 500;
      }

      #network {
        color: ${colors.orange};
      }

      #network.disconnected {
        color: ${colors.red};
      }

      window#waybar {
        background: transparent;
        color: ${colors.fg};
      }

      #waybar > box {
        padding: 4px 8px;
      }

      #workspaces,
      #clock,
      #tray,
      #cpu,
      #memory,
      #battery,
      #network,
      #language,
      #custom-dotfiles,
      #custom-recording.active {
        background: ${rgba colors.bgHard 0.95};
        border-radius: 9999px;
        margin: 0 4px;
        padding: 6px 18px;
      }

      #workspaces {
        padding: 6px 10px;
      }

      #workspaces button {
        padding: 0 16px;
        margin: 0;
        background-color: transparent;
        color: ${colors.gray};
        border: none;
        border-radius: 9999px;
      }

      #workspaces button:hover {
        background-color: ${colors.bg2};
        color: ${colors.fg};
      }

      #workspaces button.visible {
        background-color: ${colors.bg1};
        color: ${colors.fg};
      }

      #workspaces button.focused {
        background-color: ${colors.purple};
        color: ${colors.bg};
      }

      #workspaces button.urgent {
        background-color: ${colors.red};
        color: ${colors.bg};
      }

      #mode {
        background: ${colors.yellow};
        color: ${colors.bg};
        border-radius: 9999px;
        margin: 0 4px;
        padding: 6px 18px;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background: ${colors.red};
      }

      #custom-dotfiles.dirty {
        color: ${colors.yellow};
      }

      #custom-recording.active {
        color: ${colors.bg};
        background: ${colors.red};
      }

      #cpu {
        color: ${colors.blue};
      }

      #cpu.warning {
        color: ${colors.yellow};
      }

      #cpu.critical {
        color: ${colors.red};
      }

      #memory {
        color: ${colors.aqua};
      }

      #memory.warning {
        color: ${colors.yellow};
      }

      #memory.critical {
        color: ${colors.red};
      }

      #battery {
        color: ${colors.green};
      }

      #battery.charging {
        color: ${colors.blue};
      }

      #battery.warning:not(.charging) {
        color: ${colors.yellow};
      }

      #battery.critical:not(.charging) {
        color: ${colors.red};
      }

      #language {
        color: ${colors.purple};
      }
    '';
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
