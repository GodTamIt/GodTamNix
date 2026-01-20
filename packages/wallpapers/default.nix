{
  lib,
  stdenvNoCC,
  ...
}: let
  assets = ../../assets/wallpapers;

  # Filter for image files only to avoid issues with other files
  isImage = name: lib.hasSuffix ".jpg" name || lib.hasSuffix ".png" name || lib.hasSuffix ".jpeg" name;
  images = lib.filter isImage (builtins.attrNames (builtins.readDir assets));

  # Helper to clean up filenames
  # e.g. "foo.jpg" -> "foo"
  scaleName = name: lib.head (lib.splitString "." name);

  # Create a derivation for a single wallpaper file
  mkWallpaper = fileName:
    stdenvNoCC.mkDerivation {
      name = scaleName fileName;
      src = assets + "/${fileName}";

      dontUnpack = true;

      installPhase = ''
        cp $src $out
      '';

      passthru = {
        inherit fileName;
      };
    };

  # Generate the set of individual wallpaper packages
  wallpaperPackages =
    lib.foldl'
    (acc: image: acc // {"${scaleName image}" = mkWallpaper image;})
    {}
    images;

  installTarget = "$out/share/wallpapers";
in
  stdenvNoCC.mkDerivation {
    name = "godtamnix-wallpapers";
    src = assets;

    installPhase = ''
      mkdir -p ${installTarget}
      find . -type f -exec cp {} ${installTarget}/ \;
    '';

    passthru =
      {
        names = builtins.attrNames wallpaperPackages;
      }
      // wallpaperPackages;
  }
