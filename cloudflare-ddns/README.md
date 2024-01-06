# Cloudflare DDNS

A simple cronjob to update Cloudflare record with an IPv4 address.

```sh
docker create \
  -v ./git:/repos
  -e RUN_ON_STARTUP="true" \
  -e CLOUDFLARE_API_TOKEN="${TOKEN}" \
  -e CLOUDFLARE_RECORD_NAME="ipv4.example.com" \
  -e POST_COMMANDS_SUCCESS "curl -d 'Run successful 😎' ntfy.sh/mytopic" \
  -e CRON="*/10 * * * *" \ # every 10th minute
  --name cloudflare-ddns \
  ghcr.io/brettinternet/cloudflare-ddns
```

These evironment variables are also available in the `run.sh` as slots for pre/post commands:

```yaml
PRE_COMMANDS: |-
  curl -d "Oh boy, here we go again..." https://healthchecks.io/start

POST_COMMANDS_SUCCESS: |-
  curl -d "Woah it actually worked!" ntfy.sh/mytopic

POST_COMMANDS_FAILURE: curl -d "oh no 🫨" ntfy.sh/mytopic

POST_COMMANDS_INCOMPLETE: /config/uh-oh.sh

POST_COMMANDS_EXIT: curl -d "All done!" ntfy.sh/mytopic
```
