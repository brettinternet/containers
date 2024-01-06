# Update mirrors

A simple cronjob to update git mirrors. Curl is available for pre/post commands.

```sh
docker run --rm \
  -v ./git:/repos \
  -e WORKING_DIRECTORY=/repos \
  -e RUN_ON_STARTUP="true" \
  -e GIT_REMOTE_1=https://github.com/brettinternet/containers \
  -e GIT_REMOTE_2=https://github.com/brettinternet/homelab \
  -e POST_COMMANDS_SUCCESS="curl -d 'Run successful 😎' ntfy.sh/mytopic" \
  -e CRON="*/10 * * * *" \
  --name update-mirrors \
  ghcr.io/brettinternet/update-mirrors
```

These environment variables are also available in the `update.sh` as slots for pre/post commands:

```yaml
PRE_COMMANDS: |-
  curl -d "Oh boy, here we go again..." https://healthchecks.io/start

POST_COMMANDS_SUCCESS: |-
  curl -d "Woah it ran! 😮‍💨" ntfy.sh/mytopic

POST_COMMANDS_FAILURE: curl -d "oh no 🫨" ntfy.sh/mytopic

POST_COMMANDS_INCOMPLETE: /config/uh-oh.sh

POST_COMMANDS_EXIT: curl -d "All done!" ntfy.sh/mytopic
```
