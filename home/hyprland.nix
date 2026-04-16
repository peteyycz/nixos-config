{ config, pkgs, lib, isLaptop, ... }:

let
  colorsLib = import ./colors.nix { inherit lib; };
  colors = colorsLib.palette;
  inherit (colorsLib) c;

  terminal = "foot";
  menu = "rofi -terminal '${terminal}' -show drun";
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "${config.home.homeDirectory}/.local/share/backgrounds/default.jpg" ];
      wallpaper = [{
        monitor = "";
        path = "${config.home.homeDirectory}/.local/share/backgrounds/default.jpg";
        fit_mode = "cover";
      }];
    };
  };

  xdg.configFile."hyprpanel/modules.scss".text = ''
    .cmodule-dotfiles,
    .cmodule-recording {
      background-color: ${colors.bg}F2;
      color: ${colors.red};
      border-color: ${colors.red};
    }
    .cmodule-dotfiles .button-label,
    .cmodule-dotfiles .module-label {
      min-width: 0;
      padding: 0;
      margin: 0;
    }
  '';

  xdg.configFile."hyprpanel/modules.json".text = builtins.toJSON {
    "custom/dotfiles" = {
      icon = "󰊢";
      hideOnEmpty = true;
      execute = "bash -c 'cd ~/Code/src/github.com/peteyycz/nixos-config && if [ -n \"$(git status --porcelain)\" ]; then echo 1; fi'";
      interval = 30000;
      actions.onLeftClick = "${terminal} --working-directory=$HOME/Code/src/github.com/peteyycz/nixos-config $SHELL -c 'git status; exec $SHELL'";
    };
    "custom/recording" = {
      icon = "󰻂";
      label = "{}";
      hideOnEmpty = true;
      execute = "bash -c 'pgrep -x wf-recorder >/dev/null && echo REC || echo \"\"'";
      interval = 2000;
      actions.onLeftClick = "pkill -SIGINT -x wf-recorder";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = true;

    settings = {
      "$mod" = "SUPER";
      "$term" = terminal;
      "$menu" = menu;

      monitor = [ ",preferred,auto,1" ];

      exec-once = [
        "test -x $HOME/Code/src/github.com/peteyycz/scripts/@peteyycz:dev-start.sh && $HOME/Code/src/github.com/peteyycz/scripts/@peteyycz:dev-start.sh"
        "sleep 0.5 && hyprctl dispatch workspace 1 && ${terminal}"
        "1password --silent"
        "swayosd-server"
        "google-chrome-stable"
        "slack"
        "spotify"
      ];

      input = {
        kb_layout = "us,hu";
        kb_variant = ",qwerty";
        kb_options = "ctrl:nocaps,grp:alt_shift_toggle";
        follow_mouse = 1;
        sensitivity = 0.5;
        accel_profile = "adaptive";
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          disable_while_typing = true;
          middle_button_emulation = true;
        };
      };

      general = {
        gaps_in = 8;
        gaps_out = "0,12,12,12";
        border_size = 0;
        "col.active_border" = "rgb(${c colors.bgHard})";
        "col.inactive_border" = "rgb(${c colors.bg})";
        layout = "dwindle";
      };

      decoration = {
        rounding = 12;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
        };
        shadow = {
          enabled = true;
          range = 20;
          render_power = 3;
          offset = "0 5";
          color = "rgba(0000007F)";
        };
        dim_inactive = true;
        dim_strength = 0.15;
      };

      animations = {
        enabled = true;
        bezier = [
          "overshot, 0.05, 0.9, 0.1, 1.1"
          "smoothOut, 0.36, 0, 0.66, -0.56"
          "smoothIn, 0.25, 1, 0.5, 1"
        ];
        animation = [
          "windows, 1, 3, overshot, popin 80%"
          "windowsOut, 1, 2, smoothOut, popin 80%"
          "windowsMove, 1, 2, default"
          "border, 1, 6, default"
          "fade, 1, 3, smoothIn"
          "workspaces, 1, 3, smoothIn, slide"
          "layers, 1, 3, overshot, popin 80%"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      layerrule = [
        "blur on, match:namespace ^(rofi)$"
        "ignore_alpha 0.5, match:namespace ^(rofi)$"
        "blur on, match:namespace ^(hyprpanel.*)$"
        "ignore_alpha 0.5, match:namespace ^(hyprpanel.*)$"
      ];

      windowrule = [
        "workspace 2 silent, match:class ^(google-chrome)$"
        "workspace 3 silent, match:class ^(Steam)$"
        "workspace 4 silent, match:class ^(steam_app)"
        "workspace 7 silent, match:class ^(spotify)$"
        "workspace 9 silent, match:class ^(Slack)$"

        "float on, match:class ^(Steam)$"
        "tile on, match:class ^(Steam)$, match:title ^(Steam)$"
        "idle_inhibit focus, match:class ^(steam_app)"
        "idle_inhibit fullscreen, match:fullscreen 1"
        "float on, match:class ^(org\\.gnome\\.Nautilus)$"
        "float on, match:class ^(imv)$"
        "float on, match:class ^(mpv)$"
        "float on, match:class ^(org\\.gnome\\.NautilusPreviewer)$"
      ];

      bind = [
        "$mod, Return, exec, $term"
        "$mod, Q, killactive"
        "$mod, D, exec, $menu"
        "$mod, Escape, exec, loginctl lock-session"
        "$mod SHIFT, C, exec, hyprctl reload"
        "$mod SHIFT, E, exec, echo -e 'Lock\\nLogout\\nSuspend\\nShutdown\\nReboot' | rofi -dmenu -p 'Power' -i | xargs -I {} sh -c 'case {} in Lock) loginctl lock-session;; Logout) hyprctl dispatch exit;; Suspend) systemctl suspend;; Shutdown) systemctl poweroff;; Reboot) systemctl reboot;; esac'"

        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, L, movefocus, r"
        "$mod, left, movefocus, l"
        "$mod, down, movefocus, d"
        "$mod, up, movefocus, u"
        "$mod, right, movefocus, r"

        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, down, movewindow, d"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, right, movewindow, r"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        "$mod, B, togglesplit"
        "$mod, V, togglesplit"
        "$mod, W, exec, tmux-rofi"
        "$mod, E, togglesplit"
        "$mod, F, fullscreen, 0"
        "$mod SHIFT, F, togglefloating"
        "$mod, space, togglefloating"
        "$mod, A, movefocus, u"

        "$mod SHIFT, minus, movetoworkspacesilent, special:scratch"
        "$mod, minus, togglespecialworkspace, scratch"

        "$mod, R, exec, find $HOME/Code/src/github.com/peteyycz/scripts -maxdepth 1 -name '*.sh' -printf '%f\\n' | sed 's/\\.sh$//' | rofi -dmenu -p 'Scripts' -i | xargs -I {} sh -c '$HOME/Code/src/github.com/peteyycz/scripts/{}.sh'"

        ", Print, exec, grimblast save output"
        "ALT, Print, exec, grimblast save active"
        "CTRL, Print, exec, grimblast copy area"
        ''$mod, Print, exec, bash -c 'region=$(slurp) && wf-recorder -g "$region" -f ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4' ''
        "$mod SHIFT, Print, exec, pkill -SIGINT -x wf-recorder"
      ];

      bindl = [
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
      ];

      bindle = [
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  programs.hyprpanel = {
    enable = true;
    systemd.enable = true;
    settings = lib.recursiveUpdate {
      theme.font.name = "Open Runde";
      theme.font.size = "1.05rem";
      theme.font.weight = 400;
      theme.bar.floating = true;
      theme.bar.transparent = true;
      bar.launcher.icon = "󱄅";
      theme.bar.outer_spacing = "0";
      theme.bar.margin_top = "0.2em";
      theme.bar.buttons.style = "default";
      theme.bar.buttons.enableBorders = false;
      theme.bar.buttons.radius = "9999px";
      theme.bar.buttons.padding_x = "1.2rem";
      theme.bar.buttons.padding_y = "0.5rem";
      theme.bar.buttons.spacing = "0.4em";
      "theme.bar.buttons.modules.ram.spacing" = "0.9em";
      "theme.bar.buttons.modules.dotfiles.spacing" = "0";

      bar.layouts."0" = {
        left = [ "dashboard" "workspaces" "windowtitle" "media" ];
        middle = [ "clock" ];
        right = [
          "custom/recording"
          "volume"
          "bluetooth"
          "network"
        ] ++ lib.optionals isLaptop [
          "battery"
        ] ++ [
          "kbLayout"
          "custom/dotfiles"
          "notifications"
        ];
      };

      bar.workspaces.showWsIcons = true;
      bar.workspaces.showApplicationIcons = true;

      bar.clock.format = "%a %d %b  %H:%M";
      bar.clock.leftClick = "${terminal} -e cal -3";
      bar.network.leftClick = "${terminal} -e nmtui";
      bar.network.truncation = true;
      bar.network.truncation_size = 12;

    } (lib.optionalAttrs isLaptop {
      bar.battery.label = true;
    } // (import ./hyprpanel-theme.nix { inherit colors; }));
  };
}
