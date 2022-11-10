#!/usr/bin/env -S zsh -uo pipefail

commit=`git rev-parse HEAD | cut -c -7`
echo "Building commit $commit"

yarn install

if ! systemctl is-active docker &>/dev/null; then
	timeout 15s systemctl start docker
	if [ $? -eq 124 ]; then
		echo 'Docker start may be hanging... consider manual intervention:'
		echo '  rm -rf /var/run/docker'
		echo '  rm -f /var/run/docker.sock'
		echo '  systemctl start docker docker.socket'
		exit 124
	fi
fi

docker build --build-arg SOURCE_COMMIT=$commit --tag pluralcafe/mastodon:edge .

echo 'Docker image built. Push to Docker Hub with `docker push pluralcafe/mastodon:edge`.'
