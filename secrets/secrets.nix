let
  # personal_key = "ssh-rsa AAAA....";
  moby_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKdcdlNS1SO+rJHjRQWd33qvqBEZcZR8ypTQUeC9LZ4 amunozgo@broadinstitute.org ";
  keys = [
    # personal_key
    moby_key
  ];
in
{
  "service_account.json.age".publicKeys = keys;
}
