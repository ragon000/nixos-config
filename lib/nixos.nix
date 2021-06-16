{ inputs, lib, pkgsBySystem, ... }:

with lib;
with lib.my;
{
  mkHost = path: attrs @ { ... }:
    let
      system = builtins.elemAt (builtins.split "\n" (builtins.readFile "${path}/system")) 0; # i didnt find a remove whitespace function
      pkgs = pkgsBySystem.${system};
    in
    nixosSystem {
      inherit system;
      specialArgs = { inherit lib inputs system; };
      modules = [
        {
          nixpkgs.pkgs = pkgs;
          networking.hostName = mkDefault (removeSuffix ".nix" (baseNameOf path));
        }
        (filterAttrs (n: v: !elem n [ "system" ]) attrs)
        ../. # /default.nix
        (import path)
      ];
    };

  mapHosts = dir: attrs @ { ... }:
    mapModules dir
      (hostPath: mkHost hostPath attrs);

  mkNode = path: attrs @ { ... }:
    let
      bnpath = baseNameOf path;
    in
    (if traceVal (builtins.pathExists (traceVal "${path}/deployment.nix")) then {
      ${bnpath} = {
        hostname = mkDefault "${bnpath}.hailsatan.eu";
        profiles.system = {
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${baseNameOf path};
        };
      } // (import "${path}/deployment.nix");
    } else { });

  mapNodes = dir: attrs @ { ... }:
    mapModules dir
      (hostPath: mkNode hostPath attrs);




}
