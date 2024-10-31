{ config, inputs, pkgs, lib, ... }:
{
  imports =
    [
      ./hardware-configuration.nix

      ../../nixos-modules/networking/tailscale.nix
      ../../nixos-modules/services/ssh.nix
      ../../nixos-modules/system/agenix.nix
      ../../nixos-modules/system/persist.nix
      ../../nixos-modules/user
    ];

  # Don't Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-uuid/4cd8dbb3-8eea-48ff-87b1-92945be291ac";
  programs.fuse.userAllowOther = true;
  programs.sway.enable = true;
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  environment.systemPackages = [
    pkgs.wezterm
  ];

  home-manager.users.ragon = { pkgs, lib, inputs, config, ... }: {
    imports = [
      ../../hm-modules/helix
      ../../hm-modules/nushell
      ../../hm-modules/cli.nix
      ./swaycfg.nix
      ../../hm-modules/files.nix
    ];
    ragon.helix.enable = true;
    ragon.nushell.enable = true;


    # home.persistence."/persistent/home/ragon" =
    #   {
    #     directories = [
    #       ".mozilla"
    #       ".cache"
    #       ".ssh"
    #       "docs"
    #       "Images"
    #       "Downloads"
    #       "Music"
    #       "Pictures"
    #       "Documents"
    #       "Videos"
    #       "VirtualBox VMs"
    #       ".gnupg"
    #       ".ssh"
    #       ".local/share/keyrings"
    #       ".local/share/direnv"
    #       ".local/share/Steam"
    #     ];
    #     allowOther = true;
    #   };
    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
  };

  ragon = {
    user.enable = true;
    persist.enable = true;
    services = {
      ssh.enable = true;
      tailscale.enable = true;
    };

  };
}
