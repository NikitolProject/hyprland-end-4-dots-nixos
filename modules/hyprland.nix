illogical-impulse-dotfiles: inputs: { config, lib, pkgs, ... }:
let
  hypr = config.illogical-impulse.hyprland.package;
  hypr-xdg = config.illogical-impulse.hyprland.xdgPortalPackage;

  enabled = config.illogical-impulse.enable;
  hyprlandConf = config.illogical-impulse.hyprland;
in
{
  config = lib.mkIf enabled {
    home.packages = with pkgs; [
      hyprpicker
      hyprlock
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
      xwayland.enable = true;
      package = hypr;
      portalPackage = hypr-xdg;

      settings = {
        env = [
          "GIO_EXTRA_MODULES, ${pkgs.gvfs}/lib/gio/modules:$GIO_EXTRA_MODULES"
        ] ++ (lib.optionals hyprlandConf.ozoneWayland.enable [
          "NIXOS_OZONE_WL, 1"
        ]);
        exec = [
          "hyprctl dispatch submap global" # DO NOT REMOVE THIS OR YOU WON'T BE ABLE TO USE ANY KEYBIND
        ];
        submap = "global"; # This is required for catchall to work

        debug.disable_logs = false;

        monitor = hyprlandConf.monitor;
      };

      extraConfig = ''
        # Defaults
        source=~/.config/hypr/hyprland/execs.conf
        source=~/.config/hypr/hyprland/general.conf
        source=~/.config/hypr/hyprland/rules.conf
        source=~/.config/hypr/hyprland/colors.conf
        source=~/.config/hypr/hyprland/keybinds.conf

        # Custom 
        source=~/.config/hypr/custom/env.conf
        source=~/.config/hypr/custom/execs.conf
        source=~/.config/hypr/custom/general.conf
        source=~/.config/hypr/custom/rules.conf
        source=~/.config/hypr/custom/keybinds.conf
      '';

    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
        };

        listener = [
          {
            timeout = 120; # 120
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 600; # 10mins
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 900; # 15mins
            on-timeout = "systemctl suspend || loginctl suspend";
          }
        ];
      };
    };

    xdg.configFile."hypr/hyprland/scripts".source =         "${illogical-impulse-dotfiles}/.config/hypr/hyprland/scripts";
    xdg.configFile."hypr/hyprland/execs.conf".source =      "${illogical-impulse-dotfiles}/.config/hypr/hyprland/execs.conf";
    xdg.configFile."hypr/hyprland/general.conf".source =    "${illogical-impulse-dotfiles}/.config/hypr/hyprland/general.conf";
    xdg.configFile."hypr/hyprland/rules.conf".source =      "${illogical-impulse-dotfiles}/.config/hypr/hyprland/rules.conf";
    xdg.configFile."hypr/hyprland/keybinds.conf".source =   "${illogical-impulse-dotfiles}/.config/hypr/hyprland/keybinds.conf";
    xdg.configFile."hypr/hyprland/colors.conf".source =     "${illogical-impulse-dotfiles}/.config/hypr/hyprland/colors.conf";

    xdg.configFile."hypr/hyprlock".source =                 "${illogical-impulse-dotfiles}/.config/hypr/hyprlock";
    xdg.configFile."hypr/shaders".source =                  "${illogical-impulse-dotfiles}/.config/hypr/shaders";
    xdg.configFile."hypr/custom".source =                   "${illogical-impulse-dotfiles}/.config/hypr/custom";

  };
}
