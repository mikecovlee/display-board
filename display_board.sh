#!/bin/bash
echo "Preparing Covariant Script Runtime Environment..."
cs -v
echo "Starting display board..."
cs -i ./import -l ./log.txt ./display_board.csc