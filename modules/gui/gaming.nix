{ config, lib, pkgs, ... }:
let
  sources = import ../../nix/sources.nix;
  cfg = config.ragon.gui.gaming;
in
{
  options.ragon.gui.gaming.enable = lib.mkEnableOption "Enables Ragons Gaming stuff";
  config = lib.mkIf cfg.enable {
    hardware.opengl.driSupport32Bit = true;
    hardware.opengl.driSupport = true;
    hardware.opengl.enable = true;
    programs.steam.enable = true;
    hardware.steam-hardware.enable = true;
    nixpkgs.config.packageOverrides = pkgs: {
      steam = pkgs.steam.override {
        nativeOnly = true;
      };
    };
    environment.systemPackages = with pkgs; [
      steam-run-native
      lutris
      vulkan-tools
      vulkan-loader
      wineWowPackages.staging
      (winetricks.override { wine = wineWowPackages.staging; })
      gnome3.adwaita-icon-theme
    ];
    ragon.user.persistent.extraDirectories = [
      "games"
      ".steam"
      ".local/share/Steam"
    ];

  };
}
