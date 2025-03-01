#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail
set -x

echo "************ assisted tools build+publish multi arch ************"

# Fetch packet basic configuration
# shellcheck source=/dev/null
source "${SHARED_DIR}/packet-conf.sh"

echo "### Building multi arch images"
timeout --kill-after 10m 120m ssh "${SSHOPTS[@]}" "root@${IP}" bash -x - << EOF
    cd /home/assisted
    echo "${DOCKERFILE_IMAGE_PAIRS}" | tr -d '[:space:]' | awk -F , 'BEGIN{RS="|"}{printf("-f %s -t %s\n", \$1, \$2)}' | \
    while read -r params ; do
      docker buildx build --platform linux/amd64,linux/arm64,linux/ppc64le,linux/s390x . --push \$params
    done
EOF
