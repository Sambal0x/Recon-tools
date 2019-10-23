#!/bin/bash

# Author: Sambal0x
#
# Instructions : ./subdomain-enum <domain.com>


########    PLEASE SET UP VARIABLES HERE    ########
OUTDIR=~/osint           # We will create subfolders for each domain here
WORDLIST=/opt/external/osint/massdns/lists/all.txt   #custom wordlist
SLACKHOOK=https://hooks.slack.com/services/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
########    YAY, ALL DONE WITH VARIABLES    ########


function check_wildcard() {
	if [[ "$(dig @1.1.1.1 A,CNAME {test321123,testingforwildcard,plsdontgimmearesult}.$RECON_DOMAIN +short | wc -l)" -gt "1" ]]; then
		echo "Wildcard detected .. Existing :( "
		exit 1
	fi
}


###############################################  Subdomain Enumeration   ############################################

function run_amass() {
	echo "[+] Running Amass on $RECON_DOMAIN..."
	amass enum -d $RECON_DOMAIN -o $RECON_DOMAIN-subdomains.txt
}

function run_gobuster() {
	echo "[+] Running gobuster on $RECON_DOMAIN...(this could take a while)"
	gobuster dns -d $RECON_DOMAIN -w $WORDLIST -o $RECON_DOMAIN-go.txt -t 50
	cat goout.txt | cut -f 2 -d " " >> $RECON_DOMAIN-subdomains.txt	
	echo "[+] Found $(cat $RECON_DOMAIN-subdomains.txt| wc -l) so far ..."
}


function run_massdns() {
	echo "[+] Bruteforcing $RECON_DOMAIN with massdns ..."
	/opt/external/osint/massdns/scripts/subbrute.py $WORDLIST $RECON_DOMAIN \
		| massdns -r /opt/external/osint/massdns/lists/working-resolvers.txt -t A -o S -w $RECON_DOMAIN-massdns.txt 2>/dev/null

	cat $RECON_DOMAIN-massdns.txt | cut -d " " -f 1 | sed 's/.$//' | sed '/\*/d' >> $RECON_DOMAIN-subdomains.txt
	sort -u -o $RECON_DOMAIN-subdomains.txt $RECON_DOMAIN-subdomains.txt  # remove dups in files
	echo "[+] Found $(cat $RECON_DOMAIN-subdomains.txt| wc -l) so far ..."
}

function run_dnsgen() {
	# Run dnsgen to get MORE subdomains
	echo "[+] Bruteforcing $RECON_DOMAIN with dnsgen + massdns ..."
	cat $RECON_DOMAIN-subdomains.txt | dnsgen - | massdns -r /opt/external/osint/massdns/lists/working-resolvers.txt -t A -o S -w $RECON_DOMAIN-dnsgen.txt 2>/dev/null
	cat $RECON_DOMAIN-dnsgen.txt | cut -d " " -f 1 | sed 's/.$//' | sed '/\*/d' >> $RECON_DOMAIN-subdomains.txt
	sort -u -o $RECON_DOMAIN-subdomains.txt $RECON_DOMAIN-subdomains.txt  # remove dups in files
	echo "[+] Found $(cat $RECON_DOMAIN-subdomains.txt| wc -l) so far ..."
}

#############################################  Check for subdomain takeovers ########################################

function check_takeover() {
	# Analyse for Subdomain takeover
	echo "[+] Now analysing results with Subjack..."
	for i in $RECON_DOMAIN-subdomains.txt; do /root/go/bin/subjack -w $i -c /root/go/src/github.com/haccer/subjack/fingerprints.json -o $RECON_DOMAIN-stakeover.txt; done 
}

function push_to_slack() {
	# Send results to slack's web hook
	echo "[+] Sending results to slack ..."
	
	subdomains="$(cat $RECON_DOMAIN-subdomains.txt)"
	curl -X POST -H 'Content-type: application/json' --data "{'text':'## Subdomain for $RECON_DOMAIN ##\n$subdomains'}" $SLACKHOOK 2>/dev/null
		
	takeover="$(cat $RECON_DOMAIN-stakeover.txt)"
	curl -X POST -H 'Content-type: application/json' --data "{'text':'## Subdomain Takeover $RECON_DOMAIN ##\n$takeover'}" $SLACKHOOK 2>/dev/null
}

######### Main function ########

#read -p 'Enter TLD for subdomain enumeration (example: company.com): ' RECON_DOMAIN
RECON_DOMAIN=$1

# set up the directory structure
mkdir -p $OUTDIR/$RECON_DOMAIN/subdomain-recon

# change into dir - as output files from enumall go to local dir
cd $OUTDIR/$RECON_DOMAIN/subdomain-recon


# check if DNS wildcard present
check_wildcard

# Start the subdomain enumeration
run_amass
run_massdns

# Check if any subdomains were previously one before running run_dnsgen, otherwise skip this step
[ -s $OUTDIR/$RECON_DOMAIN/subdomain-recon/$RECON_DOMAIN-subdomains.txt ] && run_dnsgen 

# check of potential subdomain takeover
check_takeover

# Log that baby
push_to_slack

echo "[+] All done !"
