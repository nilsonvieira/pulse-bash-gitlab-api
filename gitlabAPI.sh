#!/bin/bash

OP=$1

source .env
load .env

getProj(){

TMPFILE=$(mktemp)
    for i in $GROUPID 
    do
        curl --location "$URL_GITLAB/api/v4/groups/$i/projects?&per_page=10000" --header "PRIVATE-TOKEN: $W_TOKEN" --header "Accept: application/json"  | jq '.[] | .name' >> $TMPFILE
        cat $TMPFILE
    done

}

getUsers(){

TMPFILE=$(mktemp)
    for i in $PROJECT_ID 
    do
        curl --location "$URL_GITLAB/api/v4/projects/$i/members/all?&per_page=10000" \
             --header "PRIVATE-TOKEN: $W_TOKEN" \
             --header 'Accept: application/json' | jq  '.[] | "--------------------------------------------", "NOME: " + .name,"USER: " + .username,"STATUS: " + .state' >> $TMPFILE
        cat $TMPFILE
    done

}

configBranches(){
# PROJECT_ID=$(curl --location "$URL_GITLAB/api/v4/groups/$GROUPID/projects/?null=null&per_page=10000" --header "PRIVATE-TOKEN: $W_TOKEN" --header 'Accept: application/json' | jq -c '.[] | .id' |  tr "\n" " ")
# echo $PROJECT_ID

    for i in $PROJECT_ID 
    do
        ## Default Branch
        curl --request PUT \
            --header "PRIVATE-TOKEN: $W_TOKEN" \
            --url "$URL_GITLAB/api/v4/projects/$i/" \
            --data "default_branch=$DEFAULT_BRANCH"

        for z in $BRANCHES 
        do
        ## Protected Branches (GITLAB PREMIUM)
            curl --request POST \
                --header "PRIVATE-TOKEN: $W_TOKEN" \
                --url "$URL_GITLAB/api/v4/projects/$i/protected_branches?name=$z&allowed_to_merge=40&allowed_to_push=0"
        done
    done
}

case $OP in

-p) getProj ;;
-u) getUsers ;;
-c) configBranches ;;
*) echo -e "Usage: \n -p for Projects \n -u for Users \n -c for Configure Branches" ;;

esac