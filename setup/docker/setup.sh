#!/bin/bash
clear;

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi



echo -e " \e[32m"
echo "   _____ _                   _        _____                 _          _____             _             ";
echo "  / ____| |                 (_)      |  __ \               | |        |  __ \           | |            ";
echo " | (___ | |_ _ __ __ _ _ __  _ ______| |__) |___  __ _  ___| |_ ______| |  | | ___   ___| | _____ _ __ ";
echo "  \___ \| __| '__/ _\` | '_ \| |______|  _  // _ \/ _\` |/ __| __|______| |  | |/ _ \ / __| |/ / _ \ '__|";
echo "  ____) | |_| | | (_| | |_) | |      | | \ \  __/ (_| | (__| |_       | |__| | (_) | (__|   <  __/ |   ";
echo " |_____/ \__|_|  \__,_| .__/|_|      |_|  \_\___|\__,_|\___|\__|      |_____/ \___/ \___|_|\_\___|_|   ";
echo "                      | |                                                                              ";
echo "                      |_|                                                                              ";
echo -e " \e[0m"
echo "Welcome to the Strapi-React-Docker Setup Script!";
echo "Please answer the following questions to setup your techstack.";


strapiMaria () {
    cat setup/docker/base.yml > docker/docker-compose.yml
    cat setup/docker/strapi4-mariadb.yml >> docker/docker-compose.yml
    cat setup/docker/react.yml >> docker/docker-compose.yml
    cat setup/docker/network.yml >> docker/docker-compose.yml
    cp setup/docker/strapi4-mariadb/Makefile.db .
    cp setup/docker/strapi4-mariadb/Makefile.cms .
    echo "include Makefile.cms" >> Makefile
    echo "include Makefile.db" >> Makefile
}

strapiSqlite () {
    cat setup/docker/base.yml > docker/docker-compose.yml
    cat setup/docker/strapi4-sqlite.yml >> docker/docker-compose.yml
    cat setup/docker/react.yml >> docker/docker-compose.yml
    cat setup/docker/network.yml >> docker/docker-compose.yml
    cp setup/docker/strapi4/Makefile.db .
    cp setup/docker/strapi4/Makefile.cms .
    echo "include Makefile.cms" >> Makefile
    echo "include Makefile.db" >> Makefile
}

setName () {
    echo -n "Set the name/domain of your project: ";
    #read the name of the project. use regex to remove spaces and any special characters. Transform to lowercase.
    read -e name;
    name=${name// /-}
    name=${name//[^a-zA-Z0-9-]/}
    name=${name,,}

    #echo "COMPOSE_PROJECT_NAME=${REPLY}" > .env;
    echo "";
    echo -e "Your COMPOSE_PROJECT_NAME will be \e[32m${name}\e[0m";
    echo "The .local domains will be:"
    echo -e " \e[32m"
    echo -e " ${name}.local \n www.${name}.local \n dev.${name}.local \n cms.${name}.local \n traefik.${name}.local"
    echo -e " \e[0m"
    #ask the user if he is satisfied with the name. if not start over until he is satisfied.
    echo " ";
    echo "Are you satisfied with the name?";
    read -p "(y/N): " -e answer;
    if [ "$answer" != "y" ]; then
      setName
    fi
}


echo " ";
echo "--------------------------------------------------------"
echo " ";
echo -n "1. We need to setup the name of this project. ";
echo "The name will be used to name the Docker container and it will generate .local-Domains from it. ";
echo -e "Spaces will be replaced by '-' eg: \e[34m my example \e[0m --> \e[32m my-example \e[0m ";
setName

mkdir apps && mkdir apps/strapi && mkdir docker
echo "COMPOSE_PROJECT_NAME=${name}" > docker/.env;

echo " ";
echo "--------------------------------------------------------"
echo " ";
echo "2. You need to select the database system. ";
echo "Would you like to use Strapi in cobination with MariaDB or SQLite?";

db=("MariaDB" "SQLite" "Quit")
select fav in "${db[@]}"; do
    case $fav in
        "MariaDB")
            echo "You have chosen: Strapi + $fav "
            strapiMaria
	    # optionally call a function or run some code here
        break
            ;;
        "SQLite")
            echo "Your choice: Strapi + $fav "
            strapiSqlite
	    # optionally call a function or run some code here
	    break
            ;;
	"Quit")
	    echo "User requested exit"
	    exit
	    ;;
        *) echo "invalid option $REPLY";;
    esac
done    

echo "CFILES=-f docker/docker-compose.yml" > .env;
echo "CFILES=-f docker/docker-compose.yml" > .env.local;

echo " ";
echo "--------------------------------------------------------"
echo " ";
echo "3. Please select, if you want to use React with JavaScript or TypeScript? ";

js=("JavaScript" "TypeScript" "Quit")
select fav in "${js[@]}"; do
    case $fav in
        "JavaScript")
            echo "You have chosen: $fav "
            react=js
	    # optionally call a function or run some code here
        break
            ;;
        "TypeScript")
            echo "Your choice: $fav "
            react=ts
	    # optionally call a function or run some code here
	    break
            ;;
	"Quit")
	    echo "User requested exit"
	    exit
	    ;;
        *) echo "invalid option $REPLY";;
    esac
done    

echo " ";
echo "--------------------------------------------------------"
echo " ";
echo "Root access is needed to do a backup of your /etc/hosts and to set the new local domains"
sudo cp /etc/hosts /etc/hosts.bak

printf "Setting local domains...."
echo "127.0.0.1    ${name}.local www.${name}.local dev.${name}.local cms.${name}.local traefik.${name}.local" | sudo tee -a /etc/hosts > /dev/null
printf '\e[1;32m%-6s\e[m' "done"
echo " ";

printf "Building the docker images...."
make build &> /dev/null & pid=$!

while kill -0 $pid 2>/dev/null
    do
        printf "."
        sleep 1
    done
if [ $? -eq 0 ]; then
    printf '\e[1;32m%-6s\e[m' "done"
else
    printf '\e[1;31m%-6s\e[m' "failed"
    exit
fi
echo " ";

printf "Starting the docker container...."
make up &> /dev/null & pid=$!

while kill -0 $pid 2>/dev/null
    do
        printf "."
        sleep 1
    done
if [ $? -eq 0 ]; then
    printf '\e[1;32m%-6s\e[m' "done"
else
    printf '\e[1;31m%-6s\e[m' "failed"
    exit
fi
echo " ";

printf "Setting up React...."
if [ ${react} == "ts" ]; then
    make ui-setup-ts ui-install &> /dev/null & pid=$!
else
    make ui-setup ui-install &> /dev/null & pid=$!
fi

while kill -0 $pid 2>/dev/null
    do
        printf "."
        sleep 1
    done
if [ $? -eq 0 ]; then
    printf '\e[1;32m%-6s\e[m' "done"
else
    printf '\e[1;31m%-6s\e[m' "failed"
    exit
fi
docker cp setup/react/vite.config.js ${name}_node:/home/node/react
echo " ";

printf "Setting up Strapi...."
make cms-install up &> /dev/null & pid=$!

while kill -0 $pid 2>/dev/null
    do
        printf "."
        sleep 1
    done
if [ $? -eq 0 ]; then
    printf '\e[1;32m%-6s\e[m' "done"
else
    printf '\e[1;31m%-6s\e[m' "failed"
    exit
fi
echo " ";

printf "Creating directories, copying vscode utils and setting .env files...."
make ui-localsetup NAME = ${name} &> /dev/null & pid=$!
while kill -0 $pid 2>/dev/null
    do
        printf "."
        sleep 1
    done
if [ $? -eq 0 ]; then
    printf '\e[1;32m%-6s\e[m' "done"
else
    printf '\e[1;31m%-6s\e[m' "failed"
    exit
fi
echo " ";

echo " ";
echo " ";
echo "--------------------------------------------------------"
echo " ";
echo -e "\e[32mDONE! \e[0m";
echo " ";
echo -e "You are ready to go now."
echo -e "Point your webbrowser to \e[32mhttp://cms.${name}.local\e[0m and create an admin user."
echo " ";
echo -e "Run \e[32mmake ui-dev\e[0m to start the React development server."