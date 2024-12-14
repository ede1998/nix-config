{
  pkgs ? import <nixpkgs> { },
  ...
}:
{
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      git
pre-commit

      git-crypt
      wl-clipboard # for wl-paste
      coreutils # for base64
    ];
  };
}
