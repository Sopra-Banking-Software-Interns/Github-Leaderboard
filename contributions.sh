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


linenum="$(grep -n "Username" README.md | tail -n 1 | awk -F ":" '{print $1}')"
if [[ $linenum != "" ]]
then
sed -i "$linenum,\$d" README.md
fi
ap=$(echo "Username       Contributions" && cat contributions.json | jq -r '.[] | [.login, .contributions] | @tsv' | column -t)  
echo "$ap" >> README.md
git add README.md
git commit -m "Update LeaderBoard in Readme"
rm contributions.sh
