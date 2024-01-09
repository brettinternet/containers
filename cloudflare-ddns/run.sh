#!/usr/bin/env bash

function run_commands {
  commands=$1
  while IFS= read -r cmd; do echo "$cmd" && eval "$cmd" ; done < <(printf '%s\n' "$commands")
}

function run_exit_commands {
  set +e
  set +o pipefail
  run_commands "${POST_COMMANDS_EXIT:-}"
}

function run {
  set -o nounset
  set -o errexit

  current_ipv4="$(curl -s https://ipv4.icanhazip.com/)"

  zone_id=$(curl -s -X GET \
      "https://api.cloudflare.com/client/v4/zones?name=${CLOUDFLARE_RECORD_NAME#*.}&status=active" \
      -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
      -H "Content-Type: application/json" \
          | jq --raw-output ".result[0] | .id"
  )

  record_ipv4=$(curl -s -X GET \
      "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?name=${CLOUDFLARE_RECORD_NAME}&type=A" \
      -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
      -H "Content-Type: application/json" \
  )

  old_ip4=$(echo "$record_ipv4" | jq --raw-output '.result[0] | .content')
  if [[ "${current_ipv4}" == "${old_ip4}" ]]; then
      printf "%s - IP Address '%s' has not changed\n" "$(date -u)" "${current_ipv4}"
      return 0
  fi

  record_ipv4_identifier="$(echo "$record_ipv4" | jq --raw-output '.result[0] | .id')"

  update_ipv4=$(curl -s -X PUT \
      "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${record_ipv4_identifier}" \
      -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
      -H "Content-Type: application/json" \
      --data "{\"id\":\"${zone_id}\",\"type\":\"${CLOUDFLARE_RECORD_TYPE:-"A"}\",\"proxied\":"${CLOUDFLARE_RECORD_PROXIED:-"false"}",\"name\":\"${CLOUDFLARE_RECORD_NAME}\",\"content\":\"${current_ipv4}\"}" \
  )

  if [[ "$(echo "$update_ipv4" | jq --raw-output '.success')" == "true" ]]; then
      printf "%s - Success - IP Address '%s' has been updated\n" "$(date -u)" "${current_ipv4}"
      return 0
  else
      printf "%s - Failed - Updating IP Address '%s' has failed\n" "$(date -u)" "${current_ipv4}"
      return 1
  fi
}

trap run_exit_commands EXIT

run_commands "${PRE_COMMANDS:-}"

start=$(date +%s)
echo Starting updates at $(date +"%Y-%m-%d %H:%M:%S")

set +e
run
rc=$?
set -e

if [ $rc -ne 0 ]; then
  if [ $rc -eq 3 ] && [ -n "${POST_COMMANDS_INCOMPLETE:-}" ]; then
      run_commands "${POST_COMMANDS_INCOMPLETE:-}"
  else
      run_commands "${POST_COMMANDS_FAILURE:-}"
  fi
fi

echo Updates successful

end=$(date +%s)
echo Finished updates at $(date +"%Y-%m-%d %H:%M:%S") after $((end-start)) seconds

[ $rc -ne 0 ] && exit $rc

run_commands "${POST_COMMANDS_SUCCESS:-}"
