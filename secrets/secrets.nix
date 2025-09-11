let
  # personal_key = "ssh-rsa AAAA....";
  personal_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKdcdlNS1SO+rJHjRQWd33qvqBEZcZR8ypTQUeC9LZ4 amunozgo@broadinstitute.org ";
  moby_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIClOuXVukvwqgE+UDxJShus+JGprTC8QIoc1G/Ege5KK";
  keys = [
    personal_key
    moby_key
  ];
in
{
  "service_account.json.age".publicKeys = keys;
}
