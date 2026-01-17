{inputs}: _final: _prev: let
  godtamnixLib = import ./default.nix {inherit inputs;};
in {
  # Expose godtamnix module functions directly
  godtamnix = godtamnixLib.flake.lib.module;

  # Expose all godtamnix lib namespaces
  inherit
    (godtamnixLib.flake.lib)
    file
    system
    theme
    base64
    ;

  inherit
    (godtamnixLib.flake.lib.file)
    getFile
    getNixFiles
    importFiles
    importDir
    importDirPlain
    importSubdirs
    importModulesRecursive
    mergeAttrs
    ;

  inherit
    (godtamnixLib.flake.lib.module)
    mkOpt
    mkOpt'
    mkBoolOpt
    mkBoolOpt'
    enabled
    disabled
    capitalize
    boolToNum
    default-attrs
    force-attrs
    nested-default-attrs
    nested-force-attrs
    decode
    ;

  # Add home-manager lib functions
  inherit (inputs.home-manager.lib) hm;
}
