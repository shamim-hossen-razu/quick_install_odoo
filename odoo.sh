# !/bin/bash

echo "***************************************************"
echo "*                                                 *"
echo "*           Odoo installation script              *"
echo "*                                                 *"
echo "*             Shamim Hossen Razu                  *"
echo "*                                                 *"
echo "***************************************************"
echo ""


echo "update && upgrade the system ..."
# Update package lists
sudo apt-get update
# Upgrade installed packages
sudo apt-get upgrade -y

echo "Installing dependencies..."

if command -v psql &> /dev/null
then
    echo "** PostgreSQL is already installed."
    echo ""
    
else
    # Install PostgreSQL
    echo "Installing PostgreSQL..."
    sudo apt-get update
    sudo apt-get install postgresql postgresql-contrib

    # Check if installation was successful
    if [ $? -eq 0 ]
    then
        echo "PostgreSQL has been successfully installed."
    else
        echo "Failed to install PostgreSQL. Please check your internet connection and try again."
        exit 1
    fi
fi

export PGPASSWORD='postgres'
psql -h localhost -p 5432 -U postgres -d postgres -c "CREATE USER odoo_dev WITH PASSWORD 'postgres';"
unset PGPASSWORD

export PGPASSWORD='postgres'
psql -h localhost -p 5432 -U postgres -d postgres -c "ALTER USER odoo_dev WITH SUPERUSER;"
unset PGPASSWORD

export PGPASSWORD='postgres'
psql -h localhost -p 5432 -U postgres -d postgres -c "CREATE DATABASE odoo11_db WITH OWNER odoo_dev;"
unset PGPASSWORD

export PGPASSWORD='postgres'
psql -h localhost -p 5432 -U postgres -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE odoo11_db to odoo_dev;"
unset PGPASSWORD

export PGPASSWORD='postgres'
psql -h localhost -p 5432 -U postgres -d postgres -c "CREATE DATABASE odoo16_db WITH OWNER odoo_dev;"
unset PGPASSWORD

export PGPASSWORD='postgres'
psql -h localhost -p 5432 -U postgres -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE odoo16_db to odoo_dev;"
unset PGPASSWORD

install_python_version() {
    local python_version=$1

    # Check if the version is already installed
    if pyenv versions --bare | grep -q "$python_version"; then
        echo "** Python $python_version is already installed."
        echo ""
    else
        # Install the Python version
        echo "Installing Python $python_version..."
        pyenv install "$python_version"

        # Check if the installation was successful
        if [ $? -eq 0 ]; then
            echo "## Python $python_version has been successfully installed."
        else
            echo "## Failed to install Python $python_version. Please check your pyenv configuration."
            exit 1
        fi
    fi
}

echo "Installing python version 3.7.~* for odoo 11"
install_python_version "3.7"

echo "Installing python version 3.10.~* for odoo 16"
install_python_version "3.10"


create_directory() {
    local dir_name=$1

    # Check if the directory already exists
    if [ -d "$dir_name" ]; then
        echo "Directory '$dir_name' already exists."
    else
        # Create the directory with full permissions (777)
        mkdir -m 777 "$dir_name"

        # Check if the directory creation was successful
        if [ $? -eq 0 ]; then
            echo "Directory $dir_name has been successfully created with full permissions."
        else
            echo "Failed to create directory $dir_name."
            exit 1
        fi
    fi
}

# create a directory named odoo and dive into it
DIRECTORY="odoo"
create_directory "$DIRECTORY"
cd "$DIRECTORY"
# /odoo

# create a directory named server and dive into it
DIRECTORY="server"
create_directory "$DIRECTORY"
cd "$DIRECTORY"
# /odoo/server


clone_odoo_repository() {
    local branch_name=$1
    local directory_name=$2

    # Check if the directory already exists
    if [ -d "$directory_name" ]; then
        echo "Directory $directory_name already exists."
        echo ""
    else
        # Clone Odoo repository with the specified branch
        echo "Cloning Odoo repository with branch $branch_name into $directory_name..."
        git clone https://www.github.com/odoo/odoo --depth 1 --single-branch --branch="$branch_name" "$directory_name"

        # Check if the cloning was successful
        if [ $? -eq 0 ]; then
            echo "Odoo repository has been successfully cloned into $directory_name."
        else
            echo "Failed to clone Odoo repository. Please check your internet connection and branch name."
            exit 1
        fi
    fi
}
clone odoo 11 and odoo 16 repository
clone_odoo_repository "11.0" "odoo-11"
clone_odoo_repository "16.0" "odoo-16"

cd odoo-11/addons
odoo11_addons_path=$(pwd)
cd ..
cd odoo/addons
odoo11_addons_path="$odoo11_addons_path,$(pwd)"
cd ..
cd ..
cd ..

cd odoo-16/addons
odoo16_addons_path=$(pwd)
cd ..
cd odoo/addons
odoo16_addons_path="$odoo16_addons_path,$(pwd)"
cd ..
cd ..
cd ..
cd ..

# odoo
DIRECTORY="envs"
create_directory "$DIRECTORY"
cd "$DIRECTORY"
# odoo/envs/

create_virtual_environment() {
    local python_version=$1
    local directory_name=$2

    pyenv global "$python_version"
    pyenv versions

    # Check if the directory already exists
    if [ -d "$directory_name" ]; then
        echo "Directory $directory_name already exists."
        echo ""
    else
        # Create a virtual environment for the specified Python version
        echo "Creating a virtual environment for Python $python_version..."
        python3 -m venv "$directory_name"

        # Check if the virtual environment creation was successful
        if [ $? -eq 0 ]; then
            echo "Virtual environment for Python $python_version has been successfully created."
        else
            echo "Failed to create virtual environment for Python $python_version."
            exit 1
        fi
    fi
}

create_virtual_environment "3.7" "odoo-11-env"
create_virtual_environment "3.10" "odoo-16-env"
pwd
source envs/odoo-11-env/bin/activate
pip install -r ../server/odoo-11/requirements.txt
source deactivate
source envs/odoo-16-env/bin/activate
pip install -r ../server/odoo-16/requirements.txt
source deactivate
cd ..
# /odoo

# create a directory named config and dive into it
# this is basically the file that will be used to run odoo
DIRECTORY="config"
create_directory "$DIRECTORY"
cd "$DIRECTORY"
# odoo/config/


# create odoo 11 config file
conf_file="odoo11.conf"

cat <<EOL > "$conf_file"
[options]
db_host = localhost
db_port = 5432
db_user = odoo_dev
db_password = postgres
xmlrpc_port = 8011
addons_path = $odoo11_addons_path
EOL

# Check if the file creation was successful
if [ $? -eq 0 ]; then
    echo "File $conf_file has been successfully created."
else
    echo "Failed to create file $conf_file."
    exit 1
fi

# create odoo 16 config file
conf_file="odoo16.conf"

cat <<EOL > "$conf_file"
[options]
db_host = localhost
db_port = 5432
db_user = odoo_dev
db_password = postgres
xmlrpc_port = 8016
addons_path = $odoo16_addons_path
EOL

# Check if the file creation was successful
if [ $? -eq 0 ]; then
    echo "File $conf_file has been successfully created."
else
    echo "Failed to create file $conf_file."
    exit 1
fi
pwd 
ls
# odoo_dev/odoo/config
pyenv global system
