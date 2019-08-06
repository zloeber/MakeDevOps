docker pull joeybaker/syncthing

docker run -d --restart=always \
  -v /srv/sync:/srv/data \
  -v /srv/syncthing:/srv/config \
  -p 22000:22000 -p 21027:21027/udp -p 8080:8080 \
  --name syncthing \
  joeybaker/syncthing