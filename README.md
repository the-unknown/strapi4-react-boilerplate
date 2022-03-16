![Docker_Strapi_React](https://i.imgur.com/NVCXLk5.jpeg)

# Docker Strapi React Boilerplate

This boilerplate will setup Docker container with React and Strapi 4. During the setup process you can choose between to following options:

* React with JavaScript
* React with TypeScript
* Strapi with SQLite
* Strapi with MariaDB

It will further setup a bunch of .local domains to ease the handling with React, Strapi and development.

## Requirements

1. You need to have docker and docker-compose setup correctly
2. Your user needs to be able to start docker container
3. You need to have `make`. If you don't have `make` install it via:

Ubuntu/Debian/Mint
```
    sudo apt install make
```

MacOS
```
    brew install make
```

## Initial Setup

1. Clone repository from git.
2. Run `make new` and answer the questions on the screen.

```bash
    git clone https://github.com/the-unknown/strapi4-react-boilerplate.git
    cd ./strapi4-react-boilerplate
    make new
```

## LOCAL Domains
This boilerplate will setup the following local domains to ease handling and development (`projectname` is just an example for this readme. You will be able to freely choose your domain-name during setup)

* `projectname.local` and `www.projectname.local` => React production build
* `dev.projectname.local:3003` => React development server 
* `cms.projectname.local` => Strapi
* `traefik.projectname.local` => Reverse Proxy


## MAKE COMMANDS
Important `make` commands are:

- `make up` - starts up the docker servers
- `make db-backup` - run this if you did changes to the strapi database and want to submit the changes to git.
- `make db-restore` - run this command if you want to restore the strapi database from a previous backup or if you got a new backup via git.
- `make ui-dev` - starts a node.js dev-server on port 3003
- `make ui-add` - add npm packages 


![Happy coding](https://media0.giphy.com/media/TilmLMmWrRYYHjLfub/giphy.gif)

Happy coding
