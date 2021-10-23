# alpine-aria2-web

```shell
docker build -t 'alpine-aria2-web' .
docker run -d --name=aria2web -p 3000:3000 -p 6800:6800 -p 51413:51413 -p 51415:61415 -v ${pwd}/data:/data alpine-aria2-web
```
