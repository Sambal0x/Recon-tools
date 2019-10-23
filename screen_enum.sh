#!/bin/bash

# Author: Sambal0x
#
# Instructions : ./screen_enum.sh <domain.com>
#
# Description: Takes screens for all the subdomains found using subdomain_enum.sh


########    PLEASE SET UP VARIABLES HERE    ########
OUTDIR=~/osint           # We will create subfolders for each domain here
WORDLIST=/opt/external/osint/massdns/lists/all.txt   #custom wordlist
SLACKHOOK=https://hooks.slack.com/services/XXXXXXXX
########    YAY, ALL DONE WITH VARIABLES    ########


function push_to_slack() {
	
	ip_add=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
	# Send results to slack's web hook
	echo "[+] Updating my master on slack ..."
	
	curl -X POST -H 'Content-type: application/json' --data "{'text':'## Screenshots for $RECON_DOMAIN completed! ##\n \
	       	http://$ip_add:1337/$RECON_DOMAIN/screen/report.html'}" $SLACKHOOK 2>/dev/null
}


######### Main function ########

#read -p 'Enter TLD for subdomain enumeration (example: company.com): ' RECON_DOMAIN
RECON_DOMAIN=$1

# set up the directory structure
mkdir -p $OUTDIR/$RECON_DOMAIN/screen/

EyeWitness --web --threads 10 --prepend-https -f $OUTDIR/$RECON_DOMAIN/subdomain-recon/$RECON_DOMAIN-subdomains.txt -d $OUTDIR/$RECON_DOMAIN/screen/ --no-prompt

push_to_slack
