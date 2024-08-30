{ inputs, ... }:
{
  imports = [
    ./home.nix
    ./packages.nix
#    ./secrets
    ./browsers
#    ./network
    ./misc
  ];
}
