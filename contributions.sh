#GET the contributors list from GIT Hub
REPO="Sopra-Banking-Software-Interns/Github-Learderboard"
curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $token"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/Sopra-Banking-Software-Interns/Github-Leaderboard/contributors | jq -r '.[] | {login, contributions}' >> contributions.txt

#Create a new game on the leaderboard on Cloud storage
ID=$(curl -s -X POST -H "Content-Type: application/json" -d '{"name": "$REPO"}' https://us-central1-js-capstone-backend.cloudfunctions.net/api/games/ | jq -r '.result | scan("Game with ID: (.+) added.")[]')

#POST the contributors list to the leaderboard
echo $ID
jq -s '.' contributions.txt >> contributions.json
rm contributions.txt

sed 's/login/user/g; s/contributions/score/g' contributions.json > contribution_final.json
rm contributions.json

# Create a database for the leaderboard
# Read the JSON file into a variable
json=$(cat contribution_final.json)
# Extract the array elements using jq
elements=$(echo "$json" | jq -c '.[]')
# Iterate over the array elements
while IFS= read -r element; do
    curl --location "https://us-central1-js-capstone-backend.cloudfunctions.net/api/games/$ID/scores/" \
    --header 'Content-Type: application/json' \
    --data "$element"
done <<< "$elements"

# sed command to delete an instance between <!--START_TABLE-->/, /<!--END_TABLE--> to update new table
sed -i '/<!--START_TABLE-->/, /<!--END_TABLE-->/d' README.md

echo "- [$(date)](https://us-central1-js-capstone-backend.cloudfunctions.net/api/games/$ID/scores/)" >> README.md

OWNER="Sopra-Banking-Software-Interns"
REPO="Github-Leaderboard"

# Make a request to fetch the contributor's information
response=$(curl -s -L \
   -H "Accept: application/vnd.github+json" \
   -H "Authorization: Bearer $token" \
   -H "X-GitHub-Api-Version: 2022-11-28" \
     "https://api.github.com/repos/$OWNER/$REPO/issues?state=closed")
echo $response | jq -r '[.[] | select( .user.login=="Tushar-2510") | .url] | length' 

# JSON data
json_data=$(curl -L "https://us-central1-js-capstone-backend.cloudfunctions.net/api/games/$ID/scores/")
json_data=$(echo "$json_data" | jq -r '.result | sort_by(-.score)')
# Loop through JSON array
echo "<!--START_TABLE-->" >> README.md
echo "| Login        | Contributions | Solved Issues |
| ------------ | ------------- | ------------- |" >> README.md
echo "$json_data" | jq -r '.[] | "| \(.user) | [\(.score)](https://github.com/Sopra-Banking-Software-Interns/Github-Leaderboard/commits?author=\(.user))' | $(echo $response | jq -r '[.[] | select( .user.login=="Tushar-2510") | .url] | length') |"' >> README.md
echo "<!--END_TABLE-->" >> README.md


