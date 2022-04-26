#!/usr/bin/env zsh
commit=`git rev-parse HEAD | cut -c -7`
echo $commit

yarn install
systemctl start docker
docker build --build-arg SOURCE_COMMIT=$commit --tag pluralcafe/mastodon:edge .

echo 'Docker image built. Push to Docker Hub with `docker push pluralcafe/mastodon:edge`.'
