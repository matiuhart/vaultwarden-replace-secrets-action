# Vaultwarden secrets replacement Actions

This action is based on a bash script that was created to integrate Vaultwarden to Github Actions for secrets replacements. Currently, Vaultwarden doesn't support Bitwarden Public API/Organization API key, it limits the usage of Github Actions snippets developed for BitWarden. Also, it can work with Bitwarden

## How it works?
The script will search defined Linux environment variables inside of the provided file as a parameter (used as a template). For each variable found in the file will search an entry (with the same variable name) in Vaultwarden, then   will create a new file with .replaced suffix adding the secrets values with envsubst.

## Inputs

**BW_CLIENTID:** Your clientId of your vw user 

**BW_CLIENTSECRET:** Your clientSecret of your vw user 

**BW_PASSWORD:** Your vw user password

**BW_SERVER:** Your vw server

**FILES_TO_REPLACE:** Files which contains secrets to replace. This variable accept multiple paths specified by line breaks (doesn't support yaml list). You can see example files in example_template_files/ folder.

## GA Variables and secrets
You need to define the below secrets and variables in your pipeline, for the clientID and clientSecret you should generate an API Key for the Vaultwarden user in *Account Settings>Security>Keys>API Keys*.

### Secrets

**BW_CLIENTID=**"user.asdqrew1d-wer4-rtret5-ert56-345654htrhrt"

**BW_CLIENTSECRET=**"Sdkmñoiwu8EAFEW$$"#$koifjow"

**BW_PASSWORD=**"kahsdhASOIJRGIELKNGLERIhI"


### Variables

**BW_SERVER=**"https://your.vaultwardenserver.yo"


## Secrets replacement file
You should define your template file replacing the secrets values as bash environment values, for eg:

*docker-compose1.yaml file*
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
You need to create new entries with the same name as the variable in your Vaultwarden server. The value is pulled from the *Password* field.
In my case, I need to create four new entries with the secret added in the password item:

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
        uses: matiuhart/vaultwarden-replace-secrets-action@master
        with:
          BW_CLIENTID: ${{ secrets.BW_CLIENTID }}
          BW_CLIENTSECRET: ${{ secrets.BW_CLIENTSECRET }}
          BW_PASSWORD: ${{ secrets.BW_PASSWORD }}
          BW_SERVER: ${{ vars.BW_SERVER }}
          FILES_TO_REPLACE: |- 
            example_template_files/docker-compose1.yaml
            example_template_files/docker-compose2.yaml
     
      - name: Get the output for docker-compose1 file
        run: cat example_template_files/docker-compose1.yaml.replaced

      - name: Get the output for docker-compose2 file
        run: cat example_template_files/docker-compose2.yaml.replaced
```
