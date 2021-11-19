{ inputs, config, lib, pkgs, ... }:
let
  isGui = config.ragon.gui.enable;
  isSway = config.ragon.gui.sway.enable;
  cfg = config.ragon.home-manager;
  i3dt = pkgs.my.i3ipc-dynamic-tiling;
  laptop = config.ragon.hardware.laptop.enable;
in
{
  config = lib.mkIf (cfg.enable && isGui && isSway) {
    home-manager.users.${config.ragon.user.username} = { pkgs, lib, ... }:
      {
        programs.alacritty = {
          enable = true;
          settings.colors.primary = {
            background = "#282828";
            foreground = "#ebdbb2";
          };
        };

        programs.waybar = {
          enable = true;
          systemd.enable = true;
          # https://git.sr.ht/~begs/dotfiles/tree/1c92a56187a56c8531f04dea17c5f96acd9e49c4/item/.config/waybar/style.css
          style = ''
                        @keyframes blink-warning {
              70% {
                color: @light;
              }

              to {
                color: @light;
                background-color: @warning;
              }
            }

            @keyframes blink-critical {
              70% {
                color: @light;
              }

              to {
                color: @light;
                background-color: @critical;
              }
            }


            /* -----------------------------------------------------------------------------
             * Styles
             * -------------------------------------------------------------------------- */

            /* COLORS */

            /* Nord */
            /*@define-color light #eceff4;
            @define-color dark #2e3440;
            @define-color warning #ebcb8b;
            @define-color critical #d08770;
            @define-color mode #4c566a;
            @define-color workspaces #5e81ac;
            @define-color workspacesfocused #81a1c1;
            @define-color sound #d8dee9;
            @define-color network #4c566a;
            @define-color memory #88c0d0;
            @define-color cpu #434c5e;
            @define-color temp #d8dee9;
            @define-color layout #5e81ac;
            @define-color battery #88c0d0;
            @define-color date #2e3440;
            @define-color time #eceff4;*/

            /* Gruvbox */
            @define-color light #ebdbb2;
            @define-color dark #282828;
            @define-color warning #fabd2f;
            @define-color critical #cc241d;
            @define-color mode #a89984;
            @define-color workspaces #458588;
            @define-color workspacesfocused #83a598;
            @define-color sound #d3869b;
            @define-color network #b16286;
            @define-color memory #8ec07c;
            @define-color cpu #98971a;
            @define-color temp #b8bb26;
            @define-color layout #689d6a;
            @define-color battery #fabd2f;
            @define-color date #282828;
            @define-color time #ebdbb2;

            /* Reset all styles */
            * {
              border: none;
              border-radius: 0;
              min-height: 0;
              margin: 0;
              padding: 0;
            }

            /* The whole bar */
            #waybar {
              background: transparent;
              color: @light;
              font-family: Terminus, Siji;
              font-size: 10pt;
              /*font-weight: bold;*/
            }

            /* Each module */
            #battery,
            #clock,
            #cpu,
            #language,
            #memory,
            #mode,
            #network,
            #pulseaudio,
            #temperature,
            #custom-alsa,
            #sndio,
            #tray {
              padding-left: 10px;
              padding-right: 10px;
            }

            /* Each module that should blink */
            #mode,
            #memory,
            #temperature,
            #battery {
              animation-timing-function: linear;
              animation-iteration-count: infinite;
              animation-direction: alternate;
            }

            /* Each critical module */
            #memory.critical,
            #cpu.critical,
            #temperature.critical,
            #battery.critical {
              color: @critical;
            }

            /* Each critical that should blink */
            #mode,
            #memory.critical,
            #temperature.critical,
            #battery.critical.discharging {
              animation-name: blink-critical;
              animation-duration: 2s;
            }

            /* Each warning */
            #network.disconnected,
            #memory.warning,
            #cpu.warning,
            #temperature.warning,
            #battery.warning {
              color: @warning;
            }

            /* Each warning that should blink */
            #battery.warning.discharging {
              animation-name: blink-warning;
              animation-duration: 3s;
            }

            /* And now modules themselves in their respective order */

            #mode { /* Shown current Sway mode (resize etc.) */
              color: @light;
              background: @mode;
            }

            /* Workspaces stuff */
            #workspaces button {
              /*font-weight: bold;*/
              padding-left: 4px;
              padding-right: 4px;
              color: @dark;
              background: @workspaces;
            }

            #workspaces button.focused {
              background: @workspacesfocused;
            }

            /*#workspaces button.urgent {
              border-color: #c9545d;
              color: #c9545d;
            }*/

            #window {
              margin-right: 40px;
              margin-left: 40px;
            }

            #custom-alsa,
            #pulseaudio,
            #sndio {
              background: @sound;
              color: @dark;
            }

            #network {
              background: @network;
              color: @light;
            }

            #memory {
              background: @memory;
              color: @dark;
            }

            #cpu {
              background: @cpu;
              color: @light;
            }

            #temperature {
              background: @temp;
              color: @dark;
            }

            #language {
              background: @layout;
              color: @light;
            }

            #battery {
              background: @battery;
              color: @dark;
            }

            #tray {
              background: @date;
            }

            #clock.date {
              background: @date;
              color: @light;
            }

            #clock.time {
              background: @time;
              color: @dark;
            }

            #pulseaudio.muted {
              /* No styles */
            }

          '';
          settings = [{
            layer = "top";
            position = "top";
            # height = 30;
            modules-left = [ "sway/workspaces" "sway/mode" "sway/window" ];
            modules-right = [ "pulseaudio" "network" "memory" "cpu" "temperature" "battery" "tray" "clock#date" "clock#time" ];
            modules = {
              battery = { format = " {capacity}%"; format-discharging = "{icon} {capacity}%"; format-icons = [ "" "" "" "" "" ]; interval = 1; states = { critical = 15; warning = 30; }; tooltip = false; };
              "clock#date" = {
                format = "{:%F}";
                interval = 60;
                tooltip = false;
              };
              "clock#time" = { format = "{:%H:%M:%S}"; interval = 1; tooltip = false; };
              cpu = { format = " {usage}%"; interval = 5; states = { critical = 90; warning = 70; }; tooltip = false; };
              memory = {
                format = " {}%";
                interval = 5;
                states = {
                  critical = 90;
                  warning = 70;
                };
              };
              network = {
                format-disconnected = "";
                format-ethernet = " {ifname}";
                format-wifi =
                  " {essid} ({signalStrength}%)";
                interval = 5;
                tooltip = false;
              };
              pulseaudio = { format = "{icon} {volume}%"; format-bluetooth = "{icon} {volume}%"; format-icons = { car = ""; default = [ "" "" ]; handsfree = ""; headphones = ""; headset = ""; phone = ""; portable = ""; }; format-muted = ""; on-click = "pavucontrol"; scroll-step = 1; };
              "sway/mode" = { format = "<span style=\"italic\"> {}</span>"; tooltip = false; };
              "sway/window" = { format = "{}"; max-length = 30; tooltip = false; };
              "sway/workspaces" = { all-outputs = false; disable-scroll = false; format = "{name}"; format-icons = { default = ""; focused = ""; urgent = ""; }; };
              temperature = {
                critical-threshold = 90;
                format = "{icon} {temperatureC}°";
                format-icons = [ "" "" "" ];
                interval = 5;
                tooltip = false;
              };
              tray = { icon-size = 21; };
            };
          }];
        };
        wayland.windowManager.sway = {
          enable = true;
          systemdIntegration = true;
          config = null;
          extraConfig = ''
                        set $mod Mod4
                        floating_modifier $mod
                        default_border pixel 2
                        default_floating_border pixel 2
                        hide_edge_borders none
                        focus_wrapping no
                        focus_follows_mouse yes
                        focus_on_window_activation smart
                        mouse_warping output
                        workspace_layout default
            
                        client.focused #4c7899 #285577 #ffffff #2e9ef4 #285577
                        client.focused_inactive #333333 #5f676a #ffffff #484e50 #5f676a
                        client.unfocused #333333 #222222 #888888 #292d2e #222222
                        client.urgent #2f343a #900000 #ffffff #900000 #900000
                        client.placeholder #000000 #0c0c0c #ffffff #000000 #0c0c0c
                        client.background #ffffff

                        # Your preferred terminal emulator
                        set $term ${pkgs.alacritty}/bin/alacritty
                        set $menu ${pkgs.wofi}/bin/wofi --show drun
                        exec_always ${i3dt}/bin/i3ipc-dynamic-tiling
                        # Disable the window title bar.
                        workspace_auto_back_and_forth yes
                        show_marks yes
            
                        # Focus next cycle.
                        bindsym $mod+j nop i3ipc_focus next

                        # Move next.
                        bindsym $mod+shift+j nop i3ipc_move next

                        # Focus previous cycle.
                        bindsym $mod+k nop i3ipc_focus prev

                        # Move previous.
                        bindsym $mod+shift+k nop i3ipc_move prev

                        # Focus previous window toggle.
                        bindsym $mod+i nop i3ipc_focus toggle

                        # Focus the other container.
                        bindsym $mod+o nop i3ipc_focus other

                        # Move to the other container.
                        bindsym $mod+shift+o nop i3ipc_move other

                        # Swap window with the other container.
                        bindsym $mod+Return nop i3ipc_move swap

                        # Toggle tabbed mode.
                        bindsym $mod+space nop i3ipc_tabbed_toggle

                        # Toggle fullscreen mode.
                        bindsym $mod+f fullscreen toggle

                        # Toggle monocle mode.
                        bindsym $mod+m nop i3ipc_monocle_toggle

                        # Toggle secondary to the side of or below of main.
                        bindsym $mod+backslash nop i3ipc_reflect

                        # Toggle secondary to the right or left hand side of main.
                        bindsym $mod+shift+backslash nop i3ipc_mirror

                        # Toggle workspace.
                        bindsym $mod+Tab workspace back_and_forth

                        # Toggle layout current container.
                        bindsym $mod+semicolon layout toggle tabbed split
                          ### Key bindings
                        #
                        # Basics:
                        #
                        # Start a terminal
                        bindsym $mod+Shift+Return exec $term

                        # Kill focused window
                        bindsym $mod+Shift+q kill

                        # Start your launcher
                        bindsym $mod+p exec $menu
                        #
            # Workspaces:
            #
                # Switch to workspace
                bindsym $mod+1 workspace number 1
                bindsym $mod+2 workspace number 2
                bindsym $mod+3 workspace number 3
                bindsym $mod+4 workspace number 4
                bindsym $mod+5 workspace number 5
                bindsym $mod+6 workspace number 6
                bindsym $mod+7 workspace number 7
                bindsym $mod+8 workspace number 8
                bindsym $mod+9 workspace number 9
                bindsym $mod+0 workspace number 10
                # Move focused container to workspace
                bindsym $mod+Shift+1 move containr to workspace number 1
                bindsym $mod+Shift+2 move container to workspace number 2
                bindsym $mod+Shift+3 move container to workspace number 3
                bindsym $mod+Shift+4 move container to workspace number 4
                bindsym $mod+Shift+5 move container to workspace number 5
                bindsym $mod+Shift+6 move container to workspace number 6
                bindsym $mod+Shift+7 move container to workspace number 7
                bindsym $mod+Shift+8 move container to workspace number 8
                bindsym $mod+Shift+9 move container to workspace number 9
                bindsym $mod+Shift+0 move container to workspace number 10
                # Note: workspaces can have any name you want, not just numbers.
                # We just use 1-10 as the default.


            


                        # Drag floating windows by holding down $mod and left mouse button.
                        # Resize them with right mouse button + $mod.
                        # Despite the name, also works for non-floating windows.
                        # Change normal to inverse to use left mouse button for resizing and right
                        # mouse button for dragging.
                        floating_modifier $mod normal

                        # Reload the configuration file
                        bindsym $mod+Shift+c reload

                        # Exit sway (logs you out of your Wayland session)
                        bindsym $mod+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'

                        #
                        # Scratchpad:
                        #
                        # Sway has a "scratchpad", which is a bag of holding for windows.
                        # You can send windows there and get them back later.
            
                        # Move the currently focused window to the scratchpad
                        bindsym $mod+Shift+minus move scratchpad
            
                        # Show the next scratchpad window or hide the focused scratchpad window.
                        # If there are multiple scratchpad windows, this command cycles through them.
                        bindsym $mod+minus scratchpad show
          '';


        };
      };
  };
}
