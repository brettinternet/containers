#!/bin/sh

SCHEDULE=${CRON:-"*/30 * * * *"}

echo "Update schedule: $SCHEDULE"

echo "${SCHEDULE} bash /update.sh" >> /etc/crontabs/root

crond -f -l 2
