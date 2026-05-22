{ config, ... }:
{
  # Decrypted plaintext file containing ONLY the OAuth client_secret
  # (single line, no trailing newline required). The matching client_id
  # is committed in config.org because Google treats it as public.
  age.secrets.org-gcal = {
    file = ../../secrets/org-gcal.age;
    path = "/home/amunoz/.org-gcal-client-secret";
    owner = "amunoz";
    group = "users";
    mode = "0600";
    symlink = false;
  };
}
