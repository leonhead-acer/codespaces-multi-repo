#!/usr/bin/env bash

script_folder="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

clone-repo()
{
    cd "${workspaces_folder}"
    if [ ! -d "${1#*/}" ]; then
        git clone "https://github.com/$1"
    else 
        echo "Already cloned $1"
    fi
}

if [ "${CODESPACES}" = "true" ]; then
    # Remove the default credential helper
    sudo sed -i -E 's/helper =.*//' /etc/gitconfig
    workspaces_folder="$(cd "${HOME}/.." && pwd)"
    
else 
    workspaces_folder="$(cd "${HOME}/workspaces" && pwd)"
fi

if [ -z "${GITHUB_USER}" ]; then
    git config --global credential.helper '!f() { sleep 1; echo "username=${GITHUB_USER}"; echo "password=${GH_TOKEN}"; }; f'
fi

if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
    git config --global credential.helper '!aws codecommit credential-helper $@'
    git config --global credential.UseHttpPath true
fi

if [ -f ./repos-to-clone.list ]; then
    while IFS= read -r repository; do
        clone-repo "$repository"
    done < ./repos-to-clone.list
fi

python3 -m pip install --upgrade pip;
python3 -m pip install virtualenv --upgrade-strategy only-if-needed;

cd "${workspaces_folder}"
folders=($(ls -d */));

for f in "${folders[@]}"
do
    cd ${f%%/};
    
    if [ ! -f ./requirements.txt ]
    then
        echo "Creating requirements.txt"
        touch ./requirements.txt;
    fi

    if [ ! -f ./.gitignore ]
    then
        echo "Creating .gitignore file"
        touch ./.gitignore;
        echo 'renv/' -> ./.gitignore;
        echo '.venv/' -> ./.gitignore;
        echo '__pycache__' -> ./.gitignore;
    fi

    if [ ! -d "./.venv" ]
    then 
        echo "Set up VIRTUAL_ENV"; 
        python3 -m venv .venv;
        echo "ready.";
    else 
        echo "VIRTUAL_ENV is set up";
    fi

    source ./.venv/bin/activate;
    echo "Virutal env:" "$VIRTUAL_ENV";
    python3 -m pip install -r requirements.txt --upgrade-strategy only-if-needed;
    python3 -m pip install ipykernel;
    python3 -m ipykernel install --user --name ${f%%/};
    source deactivate;
    cd ..;

done;

exec "$@";