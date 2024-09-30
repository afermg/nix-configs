{ inputs, ... }:
{
  imports = [
    ./home.nix
    #./packages.nix
#    ../../modules/shared/packages.nix
#    ./secrets
    ./browsers
#    ./network
    ./misc
  ];
}
