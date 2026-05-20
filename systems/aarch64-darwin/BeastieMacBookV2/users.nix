{pkgs, ...}: {
  godtamnix = {
    users = {
      godtamit = {
        fullName = "Christopher Tam";
        isTrusted = true;
        isPrimary = true;
        shell = pkgs.fish;
      };
    };
  };
}
