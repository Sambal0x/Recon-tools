#!/bin/bash

# Author: Sambal0x
#
# Instructions : ./dir_enum.sh <domain.com>


WORDLIST=/opt/external/osint/massdns/lists/all.txt   #custom wordlist


########    PLEASE SET UP VARIABLES HERE    ########
OUTDIR=~/osint           # We will create subfolders for each domain here
RECON_DOMAIN=$1
WORDLIST=/opt/SecLists/Discovery/Web-Content/raft-small-words-lowercase.txt
SLACKHOOK=https://hooks.slack.com/services/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 
########    YAY, ALL DONE WITH VARIABLES    ########


function push_to_slack() {
	# Send results to slack's web hook
	echo "[+] Sending results to slack ..."
	
	directory="$(cat $subdomains-directory.txt)"
	curl -X POST -H 'Content-type: application/json' --data "{'text':'## Found Directories for $RECON_DOMAIN ##\n$directory'}" $SLACKHOOK 2>/dev/null
}


# set up the directory structure
mkdir -p $OUTDIR/$RECON_DOMAIN/directory-recon

# change into dir - as output files from enumall go to local dir
cd $OUTDIR/$RECON_DOMAIN/directory-recon

for subdomains in $(cat $OUTDIR/$RECON_DOMAIN/subdomain-recon/$RECON_DOMAIN-subdomains.txt); do
	gobuster dir -u https://$subdomains -w $WORDLIST -l -t 50 -o $subdomains-directory.txt -e
done

push_to_slack
