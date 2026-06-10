# Shaq secrets

sops-nix encrypted secrets for the Shaq host. Recipients are defined by the
`secrets/Shaq/...` rules in the repo-root `.sops.yaml`; they're consumed in
`systems/x86_64-linux/Shaq/sops.nix`.

| File                  | sops format | Consumed as                                  |
| --------------------- | ----------- | -------------------------------------------- |
| `default.yaml`        | yaml        | `cloudflare_api_token` (ddclient)            |
| `hermes.yaml`         | yaml        | `hermes-env` (hermes-agent env file)         |
| `google-chat-sa.json` | **binary**  | full SA JSON at `/var/lib/hermes/google-chat-sa.json` |

## `google-chat-sa.json` must be encrypted as `binary`, not `json`

This is the Google service-account credential for hermes-agent's Google Chat
provider. hermes wants the **whole file** verbatim, so it's encrypted as a
binary blob (`{ "data": "ENC[...]", "sops": {...} }`) and declared with
`format = "binary"` in `sops.nix`.

Do **not** encrypt it as structured `json`. In sops-nix the `json`/`yaml`/etc.
formats are *extractors*: they parse the decrypted document and write a single
**scalar string** at `key` (defaulting to the secret name) to the output file.
They cannot emit a whole document or a sub-object. Using `format = "json"` here
produces:

- `the value of key '...' is not a string` — when `key` lands on an object, or
- `no binary data found in tree` — when `format = "binary"` is set but the file
  was encrypted structurally (no single `data` field).

Either failure aborts the entire `setupSecrets` activation, so *all* secrets
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
