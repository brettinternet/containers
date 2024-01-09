#!/bin/sh

RUN_ON_STARTUP=$(echo "$RUN_ON_STARTUP" | awk '{print tolower($0)}')

if [ "$RUN_ON_STARTUP" == "true" ]; then
  bash /run.sh
fi

SCHEDULE=${CRON:-"*/10 * * * *"}

echo "Schedule: $SCHEDULE"

echo "${SCHEDULE} bash /run.sh" > /etc/crontabs/root

crond -f -l 2
