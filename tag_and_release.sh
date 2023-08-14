#!/bin/bash

set -e


increment_version() {
  local delimiter=.
  local array=($(echo "$1" | tr $delimiter '\n'))
  array[$2]=$((array[$2]+1))
  echo $(local IFS=$delimiter ; echo "${array[*]}")
}


oldVersion=$(git tag --sort=committerdate | grep -E 'v[0-9]' | tail -1 | cut -b 2-100)

printf "Latest tag is currently v${oldVersion}\n"

updateType="minor"
while true; do
    read -e -i "$updateType" -p "What type of version update is this? [major, minor, patch]: " input
    updateType="${input:-$updateType}"
    case $updateType in
        major ) updateIndex=0; break;;
        minor ) updateIndex=1; break;;
        patch ) updateIndex=2; break;;
        * ) echo "Please choose one of the listed types.\n";;
    esac
done

printf "Incrementing $updateType version\n"
newVersion=$(increment_version "$oldVersion" "$updateIndex")

printf "\n"
printf "The new tag will be v$newVersion\n"
printf "Tag is about to be created"
for i in {1..4}; do
    printf "."
    sleep 1s
done
printf "\n"

git tag "v$newVersion"
git push origin "v$newVersion"

