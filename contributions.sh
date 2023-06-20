REPO="Sopra-Banking-Software-Interns/Application-2.0"
curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer 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"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/Sopra-Banking-Software-Interns/Application-2.0/contributors | jq -r '.[] | {login, contributions}' >> contributions.txt

ID=$(curl -s -X POST -H "Content-Type: application/json" -d '{"name": "$REPO"}' https://us-central1-js-capstone-backend.cloudfunctions.net/api/games/ | jq -r '.result | scan("Game with ID: (.+) added.")[]')

while read line; do
    login=$(echo $line | jq -r '.login')
    contributions=$(echo $line | jq -r '.contributions')
    curl -X POST -H "Content-Type: application/json" -d '{"user": "$login", "score": "$contributions"}' https://us-central1-js-capstone-backend.cloudfunctions.net/api/games/$ID/scores/
done < contributions.txt

jq -s '.' contributions.txt >> contributions.json

rm contributions.txt

# sed command to delete an instance between <!--START_TABLE-->/, /<!--END_TABLE--> to update new table
sed -i '/<!--START_TABLE-->/, /<!--END_TABLE-->/d' README.md
# JSON data
json_data=$(cat contributions.json)
# Loop through JSON array
echo "<!--START_TABLE-->" >> README.md
echo "| Login        | Contributions |
| ------------ | ------------- |" >> README.md
echo "$json_data" | jq -r '.[] | "| \(.login) | \(.contributions) |"' >> README.md
echo "<!--END_TABLE-->" >> README.md
git add README.md
git commit -m "Update LeaderBoard in Readme"

rm contributions.json
