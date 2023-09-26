#!/bin/sh -l

# Assigning values for bw-cli login
envsubst < /bw_variables_export

# Exporting bw login variables
source /bw_variables_export

FILES_TO_REPLACE=$(echo $INPUT_FILES_TO_REPLACE|  tr -s '\n' ' ')

#MY_FILE="$GITHUB_WORKSPACE/$INPUT_FILE_TO_REPLACE"

# Search secrets func
search_entries_in_file () {
  local FILE=$GITHUB_WORKSPACE/$1
  # Uncomment to run with alpine
  local MY_SECRETS=$(egrep -o '(\$)([A-Z]|[1-9]|[_]$)\w+' $FILE |awk -F "$" '{print$2}')
  
  # Uncomment to run with distro no alpine
  #local MY_SECRETS=$(grep -oP '(\$)([A-Z]|[1-9]|[_]$)\w+' $FILE|awk -F "$" '{print$2}')
  
  echo "$MY_SECRETS"
}

# bw-cli config func
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

# Get secrets from vaultwarden func
get_secrets () {
  local ENTRIES="$@"

  for entry in $ENTRIES
  do
    MY_SECRET=$(bw get password $entry)
    echo "export $entry="$MY_SECRET"" >> secrets
  done
}

# Replace secrets in file func
replace_secrets () {
  local FILE=$GITHUB_WORKSPACE/$1
  envsubst < "$FILE" > "$FILE.replaced"
}

#
## Execution
#

echo -e  "\nConfiguring Vaultwarden server access"
bw_config

for MY_FILE in $FILES_TO_REPLACE
do
  MY_SECRETS_IN_FILE=$(search_entries_in_file "$MY_FILE")

  echo -e  "\nArchivo a procesar: $MY_FILE \n"
  echo -e  "\nSecrets to replace: \n$MY_SECRETS_IN_FILE \n"

  echo -e  "\nDumping secrets for $MY_FILE...\n"
  get_secrets "$MY_SECRETS_IN_FILE"

  echo -e  "\nLoading secrets...\n"
  source secrets
  #rm secrets

  echo -e  "\nCreating new file from $MY_FILE to $MY_FILE.replaced \n"
  replace_secrets $MY_FILE
done
