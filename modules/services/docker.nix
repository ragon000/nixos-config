{ config, lib, pkgs, ... }:
let
  cfg = config.ragon.services.docker;
in
{
  options.ragon.services.docker.enable = lib.mkEnableOption "Enables docker";
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.backend = "docker";
    # virtualisation.podman.enable = true;
    virtualisation.docker.enable = true;
    # virtualisation.podman.defaultNetwork.dnsname.enable = true;
    # virtualisation.podman.dockerCompat = true;
    ragon.user.extraGroups = [ "docker" "podman" ];
    # ragon.user.persistent.extraDirectories = [ ".local/share/containers" ".cache/containers" ];
    ragon.persist.extraDirectories = [
      "/var/lib/docker"
      "/var/cache/docker"
    ];
    # virtualisation.containers.storage.settings.storage = {
    #   driver = "zfs";
    #   options.zfs.fsname = "pool/containers";
    #   options.zfs.mountopt = "nodev";
    # };
  };
}
