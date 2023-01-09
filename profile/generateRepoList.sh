#!/usr/bin/env bash

UNDER_CONSTRUCTION=( \
  $(gh repo list kleros --json name --no-archived --limit 100 --topic under-construction | jq -r '.[].name') \
  $(gh repo list proof-of-humanity --json name --no-archived --limit 100 --topic under-construction | jq -r '.[].name') \
)

LAYERS=( Frontend Middleware Backend Smart-contracts )

declare -A ICONS
ICONS=( )
ICONS['Kleros-v1']='src="../assets/kleros-symbol.svg" width="48"'
ICONS['Kleros-v2']='src="../assets/kleros-symbol.svg" width="48"'
ICONS['Governor']='src="../assets/governor.png" width="48"'
ICONS['Gnosis-Zodiac-Reality-Governor']='src="../assets/governor.png" width="48"'
ICONS['Dispute-Resolver']='src="../assets/symbol-dispute-resolver.svg" width="48"'
ICONS['Generalized-Curated-List']='src="../assets/symbol-curate.svg" width="48"'
ICONS['Token-List']='src="../assets/symbol-t2cr.svg" width="48"'
ICONS['Reality']='src="../assets/symbol-oracle.svg" width="48"'
ICONS['Moderate']='src="../assets/symbol-moderate.svg" width="48"'
ICONS['Vea']='src="../assets/symbol-vea.png" width="48"'
ICONS['Linguo']='src="../assets/symbol-linguo.svg" width="48"'
ICONS['Escrow']='src="../assets/symbol-escrow.svg" width="48"'
ICONS['Proof-Of-Humanity']='src="../assets/symbol-poh.svg" width="48"'
ICONS['Proof-Of-Humanity-v2']='src="../assets/symbol-poh.svg" width="48"'

function renderIcon() #key
{
  local product=$1
  if [[ ${ICONS[$product]} ]] 
  then 
    echo "<img alt=\"$product\" ${ICONS[$product]}><br/>"
  fi
}

function renderHeaders()
{
  echo -n "| Product |"
  for header in ${LAYERS[@]}
  do
    echo -n " $header |"
  done
  echo
  echo -n "|"
  for i in $(seq 1 $((${#LAYERS[@]} + 1 )))
  do
    echo -n "---|"
  done
  echo
}

function renderRepos() #repos
{
  local repos="$1"
  local firstRepo=true
  echo -n " |"
  for repo in $repos
  do
    if [[ "$firstRepo" == false ]]
    then
      echo -n " <br/>"
    fi
    renderRepo "$repo"
    firstRepo=false
  done
}

function renderRepo() #repo
{
    repo="$1"
    name=$(echo $repo | cut -d, -f1)
    url=$(echo $repo | cut -d, -f2)
    if [[ " ${UNDER_CONSTRUCTION[*]} " =~ (^|[[:space:]])"$name"($|[[:space:]]) ]] # if array contains an exact match
    then 
      name="$name 🚧"
    fi
    echo -n " - [_NAME_](_URL_)" \
      | sed \
        -e "s|_NAME_|$name|" \
        -e "s|_URL_|$url|"
}

echo "# Arbitrator"
renderHeaders
for product in Kleros-v1 Kleros-v2 
do
  echo -n "| $(renderIcon $product) **$product**"
  for layer in ${LAYERS[@]}
  do
    repos=$(gh repo list kleros --json name,url --no-archived --topic $product --topic $layer \
      | jq -r 'sort_by(.name) | .[] | map(.) | @csv' | tr -d '"' )
    renderRepos "$repos"
  done
  echo
done

echo "# Arbitrated"
renderHeaders
for product in Dispute-Resolver Governor Gnosis-Zodiac-Reality-Governor Generalized-Curated-List Token-List Reality Moderate Vea Linguo Escrow Claim-Manager
do
  echo -n "| $(renderIcon $product) **$product**"
  for layer in ${LAYERS[@]}
  do 
    repos=$(gh repo list kleros --json name,url --no-archived --topic $product --topic $layer \
      | jq -r 'sort_by(.name) | .[] | map(.) | @csv' | tr -d '"' )
    renderRepos "$repos"
  done
  echo
done
for product in Proof-Of-Humanity Proof-Of-Humanity-v2
do
  echo -n "| $(renderIcon $product) **$product**"
  for layer in ${LAYERS[@]}
  do 
    repos=$(gh repo list proof-of-humanity --json name,url --no-archived --topic $product --topic $layer \
      | jq -r 'sort_by(.name) | .[] | map(.) | @csv' | tr -d '"' )
    renderRepos "$repos"
  done
  echo
done


# echo -n "| $(renderIcon Proof-Of-Humanity) **Proof-Of-Humanity**"
# for layer in ${LAYERS[@]}
# do 
#   repos=$(gh repo list proof-of-humanity --json name,url --no-archived --topic $layer \
#     | jq -r 'sort_by(.name) | .[] | map(.) | @csv' | tr -d '"' )
#   renderRepos "$repos"
# done
# echo
# # Cannot add topics to Andrei's PoHv2 repos so querying them individually
# echo -n "| $(renderIcon Proof-Of-Humanity-v2) **Proof-Of-Humanity-v2**"
# repos=$(gh repo list andreimvp --json name,url --no-archived --jq '.[] | select(.name == "proof-of-humanity-interface")' | jq -sr 'sort_by(.name) | .[] | map(.) | @csv' | tr -d '"')
# renderRepos "$repos"
# echo -n " | " # middleware
# echo -n " | " # backend
# repos=$(gh repo list andreimvp --json name,url --no-archived --jq '.[] | select(.name == "ProofOfHumanityV2")' | jq -sr 'sort_by(.name) | .[] | map(.) | @csv' | tr -d '"')
# renderRepos "$repos"
echo

echo "# Developer Tools"
for repo in $(gh repo list kleros --json name,url --no-archived --topic developer-tools \
  | jq -r 'sort_by(.name) | .[] | map(.) | @csv' | tr -d '"' )
do
  renderRepo "$repo"
  echo
done

