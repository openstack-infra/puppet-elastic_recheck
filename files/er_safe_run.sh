#!/bin/bash

flock -w 3600 /var/lib/elastic-recheck/er_safe_run.lock $@
