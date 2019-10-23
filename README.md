`Usage: ./master.sh domain.com`

**subdomain_enum.sh**
* Objective: Enumerate as many subdomains for as possible for the target TLD
* Description: The script uses amass to collect valid subdomains, followed by massdns to brute-force, and finally dnsgen to mutate a list of of subdomains and re-feed it back to massdns to brute-force again.

**screen_enum.sh**
* Objective: Take screenshots of all the sites found from the subdomains. 
* Description: The script uses Eyewitness to take the screenshots. Currently I am just take screenshots on port 80,443 as this tool can take sometime and I want it to be quick.

**dir_enum.sh**
* Objective: Search for any interesting or sensitive directories in the enumerated subdomains.
* Description: The script uses gobuster to search for interesting directories. I used to use dirsearch but found that gobuster does the job quicker especially since it is written in GO.

**master.sh**
* The three (3) scripts are then combined into a master script - **master.sh**. All output is then fed to an incoming webhook on Slack so I can monitor this from the comfort of my couch. 

Write-up : https://blog.sambal0x.com/2019/10/23/Automate-it.html
