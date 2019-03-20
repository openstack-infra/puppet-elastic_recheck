#!/bin/bash

# Timeout after 4 hours as we've seen this script occasionally fail to
# exit after running for days.
flock -w 3600 /var/lib/elastic-recheck/er_safe_run.lock timeout -k 60 14400 $@
