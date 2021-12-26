{ darwin, inputs, lib, pkgsBySystem, ... }:

let
  inherit (lib) makeExtensible attrValues foldr;
  inherit (modules) mapModules;

  modules = import ./modules.nix {
    inherit lib;
    self.attrs = import ./attrs.nix { inherit lib; self = { }; };
  };

  mylib = makeExtensible (self:
    with self; mapModules ./.
      (file: import file { inherit self pkgsBySystem lib inputs darwin; }));
in
mylib.extend
  (self: super:
    foldr (a: b: a // b) { } (attrValues super))
