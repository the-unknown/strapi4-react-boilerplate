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

- `make up` - starts up the docker containers
- `make stop` - stops the docker containers
- `make down` - stops the docker containers, removes them and removes the network (your data and files will still be there).
- `make db-backup` - run this if you did changes to the strapi database and want to submit the changes to git.
- `make db-restore` - run this command if you want to restore the strapi database from a previous backup or if you got a new backup via git.
- `make ui-dev` - starts a node.js dev-server on port 3003
- `make ui-add` - add npm packages 
- `make ui-init` - runs "yarn" and "yarn build" on react.
- `make ui-build` - makes a production build of react.

## GIT AND DATA WORKFLOW
When developing in teams, everyone needs to keep up with the data. With Strapi 4.x you need to be aware of some things:

### STRAPI 4
Strapi 4 will generate a bunch of "secrets" such as: `APP_KEYS`, `JWT_SECRET` and `API_TOKEN_SALT`.
These secrets need to be kept secret (doh!) and yet every team member needs them, in order to run a local copy of Strapi.
I recommend to extract the secrets and store them in some password vault like KeePass and then pass the vault around.

### MySQL/MariaDB
If you are on a MariaDB installation, you might notice, that the `mariadb`-folder is excluded from being committed, as there is no need to do so.
When setting up a development environment from an existing strapi4-boilterplate setup, simply use the following commands to get your own local mariadb up and running:

1. If you are the lead developer, you need to backup your the database first by using the command `make db-backup`
This will do a mysql-dump of the data and place it into the folder `setup/strapi/database/`. Commit it to your repo or send it to your team members.
2. Your team members then need to pull it from git or place it into `setup/strapi/database/` followed by the following commands:
```bash
    make up #if containers are down
    make db-restore
    make cms-reinit
    make up
```
The needs to be done only once on the first run.
3. From now on, your team members only need to do the following when restoring data:
```bash
    make up #if containers are down
    make db-restore
    make up
```

### SQLite
On an SQLite installation, there is no `make cms-reinit` as there is no need for it. Just follow these steps:

1. If you are the lead developer, you need to backup your the database first by using the command `make db-backup`
This will do a mysql-dump of the data and place it into the folder `setup/strapi/database/`. Commit it to your repo or send it to your team members.
2. Your team members then need to pull it from git or place it into `setup/strapi/database/` followed by the following commands:
```bash
    make up #if containers are down
    make db-restore
    make up
```

Happy coding



![Happy coding](https://media0.giphy.com/media/TilmLMmWrRYYHjLfub/giphy.gif)

