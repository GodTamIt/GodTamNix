# Shaq secrets

sops-nix encrypted secrets for the Shaq host. Recipients are defined by the
`secrets/Shaq/...` rules in the repo-root `.sops.yaml`; they're consumed in
`systems/x86_64-linux/Shaq/sops.nix`.

| File                     | sops format | Consumed as                                                                                                                                                  |
| ------------------------ | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `default.yaml`           | yaml        | `cloudflare_api_token` (ddclient)                                                                                                                            |
| `hermes.yaml`            | yaml        | `hermes-env` (hermes-agent env file)                                                                                                                         |
| `google-chat-sa.json`    | **binary**  | full SA JSON at `/var/lib/hermes/google-chat-sa.json`                                                                                                        |
| `instagram-cookies.json` | **binary**  | full Cookie-Editor JSON at `/var/lib/hermes/workspace/cookies.json` (picked up by the `instamcp` MCP server's CWD-based fallback loader — no env var needed) |

## `google-chat-sa.json` must be encrypted as `binary`, not `json`

This is the Google service-account credential for hermes-agent's Google Chat
provider. hermes wants the **whole file** verbatim, so it's encrypted as a
binary blob (`{ "data": "ENC[...]", "sops": {...} }`) and declared with
`format = "binary"` in `sops.nix`.

Do **not** encrypt it as structured `json`. In sops-nix the `json`/`yaml`/etc.
formats are _extractors_: they parse the decrypted document and write a single
**scalar string** at `key` (defaulting to the secret name) to the output file.
They cannot emit a whole document or a sub-object. Using `format = "json"` here
produces:

- `the value of key '...' is not a string` — when `key` lands on an object, or
- `no binary data found in tree` — when `format = "binary"` is set but the file
  was encrypted structurally (no single `data` field).

Either failure aborts the entire `setupSecrets` activation, so _all_ secrets
(including `cloudflare_api_token`) go missing and unrelated units like
`ddclient.service` fail too. The fix is always the same: re-encrypt as binary.

### Editing / rotating the credential

```sh
# Edit in place (sops handles binary round-trip):
sops secrets/Shaq/google-chat-sa.json

# Or replace from a fresh service-account JSON. The --input-type binary is the
# critical flag — without it sops auto-detects .json and encrypts structurally.
sops --encrypt --input-type binary --output-type json /path/to/new-sa.json \
  > secrets/Shaq/google-chat-sa.json

# Verify it's binary-shaped (must print exactly: data, sops):
jq -r 'keys[]' secrets/Shaq/google-chat-sa.json
```

The plaintext must be a standard service-account file (`{"type":
"service_account", "project_id": ..., "private_key": ...}`) at the top level —
not wrapped under another key.

## `instagram-cookies.json` — Cookie-Editor export

Consumed by the `instamcp` MCP server (registered in
`systems/x86_64-linux/Shaq/default.nix`). hermes-agent invokes it via
`nix run nixpkgs#uv -- tool run --from instamcp instagram-mcp` — uv is
pulled from the registry on first call (cached by the nix daemon after), so
the flake doesn't need to pin a specific uv. Same binary-blob treatment as
`google-chat-sa.json` — encrypt the full document, do not let sops parse it
structurally.

### Populating it

```sh
# 1. Log into instagram.com in your browser.
# 2. Install Cookie-Editor, navigate to instagram.com, export as JSON.
# 3. Save the raw JSON somewhere outside the repo, then encrypt and ship it:
sops --encrypt --input-type binary --output-type json \
  /path/to/instagram-cookies-export.json \
  > secrets/Shaq/instagram-cookies.json
```

Sessions expire (Instagram rotates `sessionid` periodically). When the agent
starts hitting 401s, re-export and re-encrypt with the same command. The MCP
server also exposes `instagram_server action=reload_cookies` so hermes can
re-read the file without a service restart, but a fresh export is still
required.

If the cookies JSON ever needs to live alongside other keys (e.g. rotated
session alongside archived session), keep them as separate top-level entries
in one Cookie-Editor export — `INSTAGRAM_MCP_COOKIES` points at the whole
document, and `instamcp` picks the active session from the file contents.

### Cookie file format

`instamcp`'s loader (`instagram_mcp/cookie_manager.py`) auto-detects two
formats by the file's first non-whitespace byte:

| First char | Format     | Source extension                      |
| ---------- | ---------- | ------------------------------------- |
| `[` or `{` | JSON array | Cookie-Editor / EditThisCookie export |
| anything   | Netscape   | `Get cookies.txt LOCALLY` export      |

**JSON** — top-level is a JSON array of cookie objects (a single object is
also accepted and wrapped). Each entry only needs `name` and `value`;
`domain` is used to filter down to `instagram.com`. A full Cookie-Editor
entry looks like:

```json
[
  {
    "domain": ".instagram.com",
    "expirationDate": 1780000000.123,
    "hostOnly": false,
    "httpOnly": true,
    "name": "sessionid",
    "path": "/",
    "sameSite": "no_restriction",
    "secure": true,
    "session": false,
    "storeId": null,
    "value": "7123456789%3AaBcDeFg…",
    "id": 1
  },
  { "domain": ".instagram.com", "name": "ds_user_id", "value": "7123456789" },
  { "domain": ".instagram.com", "name": "csrftoken", "value": "xYz…" }
]
```

**Netscape** — tab-separated, one cookie per line
(`domain  flag  path  secure  expiry  name  value`):

```
.instagram.com	TRUE	/	TRUE	1780000000	sessionid	7123456789%3AaBcDeFg…
.instagram.com	TRUE	/	TRUE	1780000000	ds_user_id	7123456789
.instagram.com	TRUE	/	FALSE	0	csrftoken	xYz…
```

Only `sessionid` is mandatory. `csrftoken` / `ds_user_id` are nice-to-have —
the loader fetches fresh `fb_dtsg` + `lsd` CSRF tokens from Instagram's HTML
on first authenticated request, so an export containing only `sessionid`
still works. If `sessionid` is missing or its `expirationDate` is in the
past you'll get the server's friendly `🔐 Authentication required` error.

Because the file is encrypted as a **binary blob** in sops, the plaintext
is whatever Cookie-Editor / the Netscape extension produces verbatim —
don't re-shape it into `{sessionid: ..., csrftoken: ...}` and don't drop
fields the extension added.
