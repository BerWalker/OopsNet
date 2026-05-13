#!/bin/sh
# author="Sevendi Eldrige Rifki Poluan" email="sevendipoluan@gmail.com"

# Define DAQ path
DAQ_PATH="/usr/local/lib/daq"

# Define interface (default to eth0 if not set)
INTERFACE=${INTERFACE:-eth0}

# Define main configuration file
MAIN_CONF="/usr/local/etc/snort/snort.lua"

# Define additional rules file
ADDITIONAL_RULES="/usr/local/etc/rules/local.rules"

# Define whether to use additional rules
USE_ADDITIONAL_RULES=true

# Build Snort command
SNORT_CMD="snort -c $MAIN_CONF -i $INTERFACE -l /var/log/snort"

# Add additional rules option if needed
if [ "$USE_ADDITIONAL_RULES" = true ]
then
    SNORT_CMD="$SNORT_CMD -R $ADDITIONAL_RULES"
fi

# Note: Using -A alert_fast and setting log directory
SNORT_CMD="$SNORT_CMD -s 65535 -k none -A alert_fast"



echo "Starting Snort on interface $INTERFACE..."
echo "Logging to /var/log/snort"
echo "Command: $SNORT_CMD"

# Run Snort command
exec $SNORT_CMD

