#!/bin/bash
domains=("github.com" "candicejoy.com")
original_url=$(cat ./.git/config |grep "url")

for (( i=0; i<${#domains[@]}; i++ )); do
	domain=${domains[$i]}
	domain_clean=${domain//\./\\\.}
	regex="url = https://(git\.|www\.)?$domain_clean/(.*?)/(.*?)(\.git)?"

	if [[ $original_url =~ $regex ]]; then
		subdomain=${BASH_REMATCH[1]}
		username=${BASH_REMATCH[2]}
		repo=${BASH_REMATCH[3]}
		ssh_url="git@$subdomain$domain:$username/$repo"
	fi
done

if [ -z $ssh_url ]; then
	url="$1"
else
	url="$ssh_url"
fi

if [[ $original_url != $url ]]; then
	git remote set-url origin $url
	#echo "Set: $url"
fi
