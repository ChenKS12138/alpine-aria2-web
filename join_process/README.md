# join_process

join process

```shell
join_process aria2c --conf-path=/etc/aria2/aria2.conf :::: nginx -g 'daemon off;'
```

```mermaid
flowchart LR
    join_process --> |spawn|aria2c
    join_process --> |spawn|nginx
```
