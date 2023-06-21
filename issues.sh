
#!/bin/bash

OWNER="Sopra-Banking-Software-Interns"
REPO="Github-Leaderboard"
CONTRIBUTOR="Riyu44"

# Make a request to fetch the contributor's information
response=$(curl -s -L \
   -H "Accept: application/vnd.github+json" \
   -H "Authorization: Bearer $token" \
   -H "X-GitHub-Api-Version: 2022-11-28" \
     "https://api.github.com/repos/$OWNER/$REPO/issues?state=closed")

echo $response | jq -r '[.[] | select( .user.login=="Tushar-2510") | .url] | length' 
# | jq '.[]  | select( .state == "open" ) '

# # Parse the response to find the contributor's information
# contributor_info=$(echo "$response" | jq ".[] | select(.login == \"$CONTRIBUTOR\")")

# # Check if the contributor exists in the repository
# if [[ -z "$contributor_info" ]]; then
#     echo "Contributor not found in the repository."
#     exit 1
# fi

# # Get the number of issues solved by the contributor
# issues_solved=$(echo "$contributor_info" | jq ".contributions")

# # Print the number of issues solved by the contributor
# echo "Number of issues solved by $CONTRIBUTOR: $issues_solved"
