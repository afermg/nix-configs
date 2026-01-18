{
  inputs,
  user,
  ...
}:
{
  nix-homebrew = {
    inherit user;
    enable = true;
    taps = with inputs; {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "nikitabobko/homebrew-tap" = nikitabobko-cask;
      # "macos-fuse-t/homebrew-cask" = fuse-t-cask;
      # "vancluever/homebrew-input-leap" = vancluever-tap;
      "homebrew/homebrew-bundle" = homebrew-bundle;
    };
    mutableTaps = false;
    autoMigrate = true;
  };
}
