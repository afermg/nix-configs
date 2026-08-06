{
  config,
  lib,
  pkgs,
  ...
}:
let
  domain = "moby.tail5e510f.ts.net";
  ownerJid = "alan@${domain}";
  botJid = "pi@${domain}";
  configPath = "${config.xdg.configHome}/pi-msg/config.json";
  workspace = "${config.home.homeDirectory}/Documents/pi";

  piMsg = pkgs.buildGoModule rec {
    pname = "pi-msg";
    version = "0.3.0";

    src = pkgs.fetchFromGitHub {
      owner = "zachpmanson";
      repo = "pi-msg";
      rev = "f97c9dd1cbba60fd56a1bbec35bf24cce41ab084";
      hash = "sha256-wQC+H+qz23b8Jn9gbnlBcILwBPMOGcWEwry5vFUHsy0=";
    };

    vendorHash = "sha256-9wjQDjRsdcuzuWMNar6BDtGWlbyqQUBY8mtv/I+zzU4=";

    meta = {
      description = "Bridge the Pi coding agent to XMPP";
      homepage = "https://github.com/zachpmanson/pi-msg";
      license = lib.licenses.mit;
      mainProgram = "pi-msg";
    };
  };

  registerAccounts = pkgs.writeShellApplication {
    name = "pi-msg-register-accounts";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      set -euo pipefail

      domain=${lib.escapeShellArg domain}
      config=${lib.escapeShellArg configPath}
      ctl=(
        sudo -u ejabberd /run/current-system/sw/bin/ejabberdctl
        --config /etc/ejabberd/ejabberd.yml
        --ctl-config /etc/ejabberd/ejabberdctl.cfg
        --spool /var/lib/ejabberd
        --logs /var/log/ejabberd
      )

      if ! systemctl --quiet is-active ejabberd.service; then
        echo "ejabberd is not running; deploy the NixOS configuration first" >&2
        exit 1
      fi
      if [[ ! -r "$config" ]]; then
        echo "pi-msg's agenix config is not available at $config" >&2
        exit 1
      fi

      read -r -s -p "New password for ${ownerJid}: " owner_password
      echo
      read -r -s -p "Repeat password: " owner_password_confirm
      echo
      if [[ -z "$owner_password" || "$owner_password" != "$owner_password_confirm" ]]; then
        echo "Passwords were empty or did not match" >&2
        exit 1
      fi

      bot_password=$(jq -er '.accounts.default.password' "$config")

      set_password() {
        local user=$1 password=$2
        if "''${ctl[@]}" check_account "$user" "$domain" >/dev/null 2>&1; then
          "''${ctl[@]}" change_password "$user" "$domain" "$password"
          echo "Updated $user@$domain"
        else
          "''${ctl[@]}" register "$user" "$domain" "$password"
          echo "Created $user@$domain"
        fi
      }

      set_password alan "$owner_password"
      set_password pi "$bot_password"
      unset owner_password owner_password_confirm bot_password

      systemctl --user try-restart pi-msg.service || true
      echo
      echo "Accounts ready:"
      echo "  phone: ${ownerJid}"
      echo "  bot:   ${botJid}"
    '';
  };
in
{
  age.secrets.pi-msg = {
    file = ../../../../secrets/pi-msg.age;
    path = configPath;
    mode = "0600";
  };

  home.packages = [
    piMsg
    registerAccounts
  ];

  home.file."Documents/pi/AGENTS.md".text = ''
    # Remote Pi workspace

    This is the conservative default working directory for Pi sessions driven
    from a phone through pi-msg. The user's source repositories are under
    `~/.local/share/src`. Ask which repository to use before changing one when
    the request does not identify it clearly.

    A persistent Emacs server is normally available on this machine. Use the
    emacs-pair skill when the user asks to inspect, manipulate, or display live
    Emacs buffers. Avoid editing an open modified buffer directly on disk.
  '';

  systemd.user.services.pi-msg = {
    Unit = {
      Description = "XMPP bridge for the Pi coding agent";
      After = [
        "agenix.service"
        "network-online.target"
      ];
      Requires = [ "agenix.service" ];
    };
    Service = {
      ExecStart = "${piMsg}/bin/pi-msg";
      WorkingDirectory = workspace;
      Environment = [
        "PI_MSG_CONFIG=${configPath}"
        "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin"
      ];
      Restart = "on-failure";
      RestartSec = "10s";
      UMask = "0077";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
