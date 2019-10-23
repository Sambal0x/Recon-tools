#!/bin/bash

# Author: Sambal0x
# Description: This tool is the master script to enumerate all subdomains for a single TLD target. Screenshots and directories
# 	       output are also sent to the Slack for viewing.
# Date: 23 Oct 2019

RECON_DOMAIN=$1

#step 1 - Collect All subdomains 
./subdomain_enum.sh $RECON_DOMAIN

#step 2 - Take screenshots of domains
./screen_enum.sh $RECON_DOMAIN

#step 3 - Directory enumerate all found subdomains
./dir_enum.sh $RECON_DOMAIN
