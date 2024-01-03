#!/bin/sh

RUN_ON_STARTUP=$(echo "$RUN_ON_STARTUP" | awk '{print tolower($0)}')

if [ "$RUN_ON_STARTUP" == "true" ]; then
  bash /update.sh
fi

SCHEDULE=${CRON:-"*/30 * * * *"}

echo "Update schedule: $SCHEDULE"

echo "${SCHEDULE} bash /update.sh" >> /etc/crontabs/root

crond -f -l 2
