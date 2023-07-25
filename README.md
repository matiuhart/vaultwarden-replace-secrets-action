# Vaultwarden/Bitwarden secrets replacement solution

This action is based on a bash script wich was created to integrate Vaultwarden to Github Actions for secrets replacements. Currently, Vault Warden, doesn't supports Bitwarden Public API/Organization API key, this limit the usage of Github Actions snippets developped for Bit Warden. Also it can works with Bitwarden

## How it works?
The script will search defined Linux environment variables inside of the provided file as parameter (used as a template). For each variable founded in file will search an entry (with the same variable name) in Vaultwarden, then   will create a new file with .replaced suffix adding the secrets values with envsubst.

## Inputs
**BW_CLIENTID:** Your clientId of your vw/bw user 

**BW_CLIENTSECRET:** Your clientSecret of your vw/bw user 

**BW_PASSWORD:** Your vw/bw user password

**BW_SERVER:** Your vw/bw server

**FILE_TO_REPLACE:** File wich contains secrets. The secrets are replaced with envsubst so you need define it as            
                $MY_SECRET_NAME in the vw entry name and the template secret file (You can see an example file in deployments/docker-compose.yaml)

## GA Variables and secrets
You need to define the bellow secrets and variables in you pipeline, for the clientID and clientSecret you will should to generate an API Key for the vaultwarden user in *Account Settings>Security>Keys>API Keys*.

### Secrets

**BW_CLIENTID=**"user.asdqrew1d-wer4-rtret5-ert56-345654htrhrt"

**BW_CLIENTSECRET=**"Sdkmñoiwu8EAFEW$$"#$koifjow"

**BW_PASSWORD=**"kahsdhASOIJRGIELKNGLERIhI"


### Variables

**BW_SERVER=**"https://your.vaultwardenserver.yo"


## Secrets replacement file
You should define your template file replacing the secrets values as bash environment value, for eg:

*docker-compose.yaml file*
```
version: "3.7"

services:
  wp:
    build:
      context: .
      dockerfile: Dockerfile
    environment:
      WORDPRESS_DB_USER: $WORDPRESS_DB_USER
      WORDPRESS_DB_PASSWORD: $WORDPRESS_DB_PASSWORD
      WORDPRESS_DB_NAME: sarasa
      WORDPRESS_DB_HOST: 172.31.3.8
      WORDPRESS_DB_CHARSET: utf8mb4
      WORDPRESS_DEBUG: 0
      WORDPRESS_CONFIG_EXTRA: |
        'access-key-id' => '$BUCKET_ACCESS_KEY_ID',
        'secret-access-key' => '$BUCKET_SECRET_ACCESS_KEY',)));
    restart: unless-stopped
```

## Vaultwarden Configs
You need to create new entries with the same name as varibles in your server. The value is get it from the *Password* field.
In my case, I need to create three new entries with the secret added in password item:

```
        Secret Name                   Password value
    WORDPRESS_DB_USER                   my_wp_user
    WORDPRESS_DB_PASSWORD               my_wp_user_pass
    BUCKET_ACCESS_KEY_ID                my_bucket_a_key
    BUCKET_SECRET_ACCESS_KEY            my_bucket_s_key
```

## GA execution
```
on: [push]

jobs:
  hello_world_job:
    runs-on: ubuntu-latest
    name: Vault Warden secrets replacement
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      
      - name: secrets replacement
        uses: matiuhart/vaultwareden-replace-secrets-action@v1
        id: secret_replace
        with:
          BW_CLIENTID: ${{ secrets.BW_CLIENTID }}
          BW_CLIENTSECRET: ${{ secrets.BW_CLIENTSECRET }}
          BW_PASSWORD: ${{ secrets.BW_PASSWORD }}
          BW_SERVER: ${{ vars.BW_SERVER }}
          FILE_TO_REPLACE: docker-compose.yaml
      
      - name: Get the output time
        run: cat docker-compose.yaml.replaced
```