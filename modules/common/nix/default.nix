{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Basic utilities
    btop
    curl
    dust
    eza
    git
    fish
    procs
    ripgrep
    tmux
    vim
    zsh

    libva-utils
    pciutils
  ];
}
