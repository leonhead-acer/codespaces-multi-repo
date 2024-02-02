#!/usr/bin/env bash

# script_folder="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
# workspaces_folder="$(cd "${script_folder}/.." && pwd)"

# clone-repo()
# {
#     cd "${workspaces_folder}"
#     if [ ! -d "${1#*/}" ]; then
#         git clone "https://github.com/$1"
#     else 
#         echo "Already cloned $1"
#     fi
# }

# if [ "${CODESPACES}" = "true" ]; then
#     # Remove the default credential helper
#     sudo sed -i -E 's/helper =.*//' /etc/gitconfig

#     # Add one that just uses secrets available in the Codespace
#     git config --global credential.helper '!f() { sleep 1; echo "username=${GITHUB_USER}"; echo "password=${GH_TOKEN}"; }; f'
# fi

# if [ -f ./repos-to-clone.list ]; then
#     while IFS= read -r repository; do
#         clone-repo "$repository"
#     done < ./repos-to-clone.list
# fi

python3 -m pip install --upgrade pip --root-user-action=ignore;
python3 -m pip install virtualenv --upgrade-strategy only-if-needed --root-user-action=ignore;

folders=($(ls -d */));

for f in "${folders[@]}"
do
    cd ${f%%/};
    
    if [ ! -f ./requirements.txt ]
    then
        echo "Creating requirements.txt"
        touch ./requirements.txt;
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
    python3 -m pip install -r requirements.txt --upgrade-strategy only-if-needed --root-user-action=ignore;
    python3 -m pip install ipykernel --root-user-action=ignore;
    python3 -m ipykernel install --user --name ${f%%/};
    deactivate;
    cd ..;

done
