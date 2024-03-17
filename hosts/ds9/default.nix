{ config, inputs, pkgs, lib, ... }:
let
  pubkeys = import ../../data/pubkeys.nix;
  caddy-with-plugins = import ./custom-caddy.nix { inherit pkgs; };
in
{
  imports =
    [
      ./hardware-configuration.nix

      ./backup.nix
      ./plex.nix
      ./samba.nix

      ../../nixos-modules/networking/tailscale.nix
      ../../nixos-modules/services/docker.nix
      ../../nixos-modules/services/libvirt.nix
      ../../nixos-modules/services/msmtp.nix
      ../../nixos-modules/services/paperless.nix
      ../../nixos-modules/services/photoprism.nix
      ../../nixos-modules/services/samba.nix
      ../../nixos-modules/services/ssh.nix
      ../../nixos-modules/services/caddy
      ../../nixos-modules/system/agenix.nix
      ../../nixos-modules/system/fs.nix
      ../../nixos-modules/system/persist.nix
      ../../nixos-modules/system/security.nix
      ../../nixos-modules/user
    ];

  # Don't Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;

  # power save stuffzies
  services.udev.path = [ pkgs.hdparm ];
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTRS{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -S 60 -B 100 /dev/%k"
  '';

  services.syncthing.enable = true;
  services.syncthing.user = "ragon";

  programs.mosh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  networking.useDHCP = true;
  networking.bridges."br0".interfaces = [ ];
  networking.hostId = "7b4c2932";
  networking.firewall.allowedTCPPorts = [ 9000 25565 ];
  boot.initrd.network = {
    enable = true;
    postCommands = ''
      zpool import rpool
      zpool import spool
      echo "zfs load-key -a; killall zfs" >> /root/.profile
    '';
    ssh = {
      enable = true;
      port = 2222;
      hostKeys = [
        "/persistent/etc/nixos/secrets/initrd/ssh_host_rsa_key"
        "/persistent/etc/nixos/secrets/initrd/ssh_host_ed25519_key"
      ];
      authorizedKeys = pubkeys.ragon.computers;

    };

  };
  boot.kernel.sysctl."fs.inotify.max_user_instances" = 512;

  # Immutable users due to tmpfs
  users.mutableUsers = false;

  users.users.bzzt = {
    description = "bzzt server service user";
    home = "/var/lib/bzzt";
    createHome = true;
    isSystemUser = true;
    group = "bzzt";
  };
  users.groups.bzzt = { };
  users.users.minecraft = {
    description = "Minecraft server service user";
    home = "/var/lib/minecraft";
    createHome = true;
    isSystemUser = true;
    group = "minecraft";
  };
  users.groups.minecraft = { };
  environment.systemPackages = [ pkgs.jdk pkgs.jdk17 pkgs.borgbackup pkgs.docker-compose pkgs.docker ];

  services.smartd = {
    enable = true;
    extraOptions = [ "--interval=7200" ];
    notifications.test = true;
  };
  nixpkgs.overlays = [
    (self: super: {
      zfs = super.zfs.override { enableMail = true; };
    })
  ];

  services.zfs.zed.settings = {
    ZED_EMAIL_ADDR = [ "root" ];
    ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
    ZED_EMAIL_OPTS = "@ADDRESS@";

    ZED_NOTIFY_INTERVAL_SECS = 7200;
    ZED_NOTIFY_VERBOSE = true;

    ZED_USE_ENCLOSURE_LEDS = false;
    ZED_SCRUB_AFTER_RESILVER = true;
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.ionos.path;
  services.caddy = { # ragon.services.caddy is enabled
    globalConfig = ''
      acme_dns ionos {
        api_token "{$IONOS_API_KEY}"
      }
    '';
    virtualHosts."*.hailsatan.eu".extraConfig = ''
      @paperless host paperless.hailsatan.eu
      handle @paperless {
        reverse_proxy ${config.ragon.services.paperless.location}
      }
      @photos host photos.hailsatan.eu
      handle @photos {
        reverse_proxy ${config.ragon.services.photoprism.location}
      }
      @bzzt-api host bzzt-api.hailsatan.eu
      handle @bzzt-api {
        reverse_proxy http://127.0.0.1:5001
      }
      @bzzt-lcg host bzzt-lcg.hailsatan.eu
      handle @bzzt-lcg {
        reverse_proxy http://127.0.0.1:5003
      }
      @bzzt host bzzt.hailsatan.eu
      handle @bzzt {
        reverse_proxy http://127.0.0.1:5002
      }
      handle {
        abort
      }
    '';
  };

  home-manager.users.ragon = { pkgs, lib, inputs, config, ...}: {
      imports = [
        ../../hm-modules/nvim
        ../../hm-modules/zsh
        ../../hm-modules/tmux
        ../../hm-modules/xonsh
        ../../hm-modules/cli.nix
        ../../hm-modules/files.nix
      ];
      ragon.xonsh.enable = true;

      programs.home-manager.enable = true;
      home.stateVersion = "23.11";
  };

  ragon = {
    agenix.secrets."ionos" = { };
    user.enable = true;
    persist.enable = true;
    persist.extraDirectories = [ "/var/lib/syncthing" config.services.plex.dataDir "/var/lib/minecraft" "/var/lib/bzzt" ];

    services = {
      caddy.enable = true;
      docker.enable = true;
      ssh.enable = true;
      msmtp.enable = true;
      photoprism.enable = true;
      tailscale.enable = true;
      tailscale.exitNode = true;
      tailscale.extraUpCommands = "--advertise-routes=10.0.0.0/16";
      libvirt.enable = true;
      paperless.enable = true;
    };

  };
}
