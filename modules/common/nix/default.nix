{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    btop
    curl
    dust
    eza
    git
    fish
    procs
    ripgrep
    vim
    zsh
  ];
}
