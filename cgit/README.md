# cgit

[cgit](https://git.zx2c4.com/cgit/) is a git web frontend.

Use [cgit options](https://git.zx2c4.com/cgit/tree/cgitrc.5.txt) to configure the server.

Example `docker-compose.yaml`

```yaml
services:
  cgit:
    image: ghcr.io/brettinternet/cgit:latest
    environment:
      ROOT_TITLE: "git.${MY_DOMAIN}"
      ROOT_DESC: My git repos
      ROOT_README: /srv/git/README.md
      SECTION_FROM_STARTPATH: 1
      NOPLAINEMAIL: 1
    volumes:
      - ./git:/srv/git
```
