{ config, lib, pkgs, ... }:
with lib;
with lib.my;
let
  cfg = config.ragon.services.ddns;
  domain = config.ragon.services.nginx.domain;
  dataDir = "/var/lib/inadyn";
  cacheDir = "/var/cache/inadyn";
  #  checkipv6 = pkgs.writeScript "checkipv6.sh" ''
  #    #!${pkgs.bash}/bin/bash
  #    ${pkgs.iproute2}/bin/ip address show scope global | grep inet6 | ${pkgs.gawk}/bin/awk '{print substr($$2, 1, length($$2)-3)}' | head -n 1
  #  '';
in
{
  options.ragon.services.ddns.enable = mkEnableOption "Enables CloudFlare DDNS to the domain specified in ragon.services.nginx.domain and all subdomains";
  options.ragon.services.ddns.ipv4 = mkBoolOpt true;
  options.ragon.services.ddns.ipv6 = mkBoolOpt true;
  config = mkIf cfg.enable {
    systemd.services.inadyn = {
      description = "inadyn DDNS Client";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = rec {
        Type = "simple";
        ExecStart =
          pkgs.writeScript "run-inadyn.sh" ''
            #!${pkgs.bash}/bin/bash
            export PATH=$PATH:${pkgs.bash}/bin/bash # idk if that helps
            source ${config.age.secrets.cloudflareAcme.path}
            cat >/run/${RuntimeDirectory}/inadyn.cfg <<EOF
            period = 180
            user-agent = Mozilla/5.0
            allow-ipv6 = true
            ${optionalString cfg.ipv4 ''
              # ipv4
              provider cloudflare.com:1 {
                checkip-server = api.ipify.org
                username = ${domain}
                password = $CLOUDFLARE_DNS_API_TOKEN
                hostname = ${domain}
              }
            ''}
            ${optionalString cfg.ipv6 ''
              # ipv6
              provider cloudflare.com:2 {
                checkip-server = api64.ipify.org
                username = ${domain}
                password = $CLOUDFLARE_DNS_API_TOKEN
                hostname = ${domain}
              }
            ''}
            EOF
            exec ${pkgs.inadyn}/bin/inadyn -n --cache-dir=${cacheDir} -f /run/${RuntimeDirectory}/inadyn.cfg
          '';
        RuntimeDirectory = StateDirectory;
        StateDirectory = builtins.baseNameOf dataDir;
      };
    };
    systemd.tmpfiles.rules = [
      "d ${cacheDir} 1777 root root 10m"
    ];
    ragon.agenix.secrets.cloudflareAcme = { };
  };
}
