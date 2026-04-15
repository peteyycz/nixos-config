{ config, pkgs, lib, ... }:

let
  gmailToken = pkgs.writeShellScriptBin "gmail-token" ''
    set -euo pipefail

    CACHE_DIR="''${XDG_RUNTIME_DIR:-/tmp}"
    CACHE="$CACHE_DIR/gmail-token.cache"

    if [ -f "$CACHE" ] && [ $(( $(date +%s) - $(${pkgs.coreutils}/bin/stat -c %Y "$CACHE") )) -lt 3000 ]; then
      cat "$CACHE"
      exit 0
    fi

    CLIENT_ID=$(op read "op://Personal/aerc-integration/client_id")
    CLIENT_SECRET=$(op read "op://Personal/aerc-integration/client_secret")
    REFRESH_TOKEN=$(op read "op://Personal/aerc-integration/refresh_token")

    TOKEN=$(${pkgs.curl}/bin/curl -s https://oauth2.googleapis.com/token \
      -d client_id="$CLIENT_ID" \
      -d client_secret="$CLIENT_SECRET" \
      -d refresh_token="$REFRESH_TOKEN" \
      -d grant_type=refresh_token \
      | ${pkgs.jq}/bin/jq -r .access_token)

    umask 077
    printf '%s' "$TOKEN" > "$CACHE"
    printf '%s' "$TOKEN"
  '';
in
{
  home.packages = [ gmailToken pkgs.aerc ];

  accounts.email.accounts.risingstack = {
    primary = true;
    address = "p.czibik@risingstack.com";
    realName = "Peter Czibik";
    userName = "p.czibik@risingstack.com";
    imap.host = "imap.gmail.com";
    smtp.host = "smtp.gmail.com";
    aerc = {
      enable = true;
      extraAccounts = {
        source = "imaps+oauthbearer://p.czibik%40risingstack.com@imap.gmail.com:993";
        outgoing = "smtps+oauthbearer://p.czibik%40risingstack.com@smtp.gmail.com:465";
        source-cred-cmd = "gmail-token";
        outgoing-cred-cmd = "gmail-token";
        copy-to = "[Gmail]/Sent Mail";
        from = "Peter Czibik <p.czibik@risingstack.com>";
      };
    };
  };

  programs.aerc = {
    enable = true;
    extraConfig = {
      general.unsafe-accounts-conf = true;
      ui = {
        index-columns = "date<20,name<17,flags>4,subject<*";
        timestamp-format = "2006-01-02 15:04";
        this-day-time-format = "15:04";
      };
    };
  };
}
