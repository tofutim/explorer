#!/bin/bash
RUNNER=`whoami`
echo "RUNNER: $RUNNER"
SUDORUNNER=`sudo whoami`
echo "SUDORUNNER: $SUDORUNNER"
sudo apt install git
