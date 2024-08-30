{ inputs, ... }:
{
  imports = [
    ./home.nix
    ./packages.nix
    ../common/vscode.nix
  ];
}
