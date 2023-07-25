#!/bin/sh -l


envsubst < /bw_variables_export

source /bw_variables_export

MY_FILE="$GITHUB_WORKSPACE/$INPUT_FILE_TO_REPLACE"


search_entries_in_file () {
  # Uncomment to run with alpine
  local MY_SECRETS=$(egrep -o '(\$)([A-Z]|[1-9]|[_]$)\w+' $MY_FILE |awk -F "$" '{print$2}')
  
  # Uncomment to run with distro no alpine
  #local MY_SECRETS=$(grep -oP '(\$)([A-Z]|[1-9]|[_]$)\w+' $MY_FILE|awk -F "$" '{print$2}')
  
  echo "$MY_SECRETS"
}

bw_config () {
  bw config server "$BW_SERVER"

  LOGIN_STATUS=$(bw login --check)

  if [ "$LOGIN_STATUS" != "\n You are logged in! \n" ]
  then
      bw login --apikey
  fi

  # Getting bw session ID
  echo "export BW_SESSION=`bw unlock --passwordenv BW_PASSWORD --raw`" > ./bw_session
  source ./bw_session

  bw sync -f
}


get_secrets () {
  local ENTRIES="$@"

  #echo -e "\nI'll recover values for the next entries: \n$ENTRIES"
  
  for entry in $ENTRIES
  do
    MY_SECRET=$(bw get password $entry)
    echo "export $entry="$MY_SECRET"" >> secrets
  done
}

replace_secrets () {
  envsubst < "$MY_FILE" > "$MY_FILE.replaced"
}

#
## Execution
#

MY_SECRETS_IN_FILE=$(search_entries_in_file "$MY_FILE")

echo -e  "\nSecrets to replace: \n$MY_SECRETS_IN_FILE \n"

echo -e  "\nConfiguring bw access"
bw_config

echo -e  "\nCreating secrets file...\n"
get_secrets "$MY_SECRETS_IN_FILE"

# echo -e  "\nContenido de archivo secrets...\n"
# cat secrets

echo -e  "\nLoading secrets...\n"
source secrets
rm secrets

echo -e  "\nCreating new file from $MY_FILE to $MY_FILE.replaced \n"
replace_secrets
