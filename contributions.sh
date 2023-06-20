#GET the contributors list from GIT Hub
REPO="Sopra-Banking-Software-Interns/Application-2.0"
curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer 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"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/Sopra-Banking-Software-Interns/Application-2.0/contributors | jq -r '.[] | {login, contributions}' >> contributions.txt

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


