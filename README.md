# Odoo Installation Script

This project is created for really easy and quick installation of odoo. It will create necessary directory and clone odoo source code, create configuration file, install postgres, create user and database on postgres, create virtual environment and install dependencies into it and every other things that you need to do for installing odoo.  So you don't need to take much hassle of how to install odoo. Instead you can dive directly into developing modules for your use cases.

## Executing scripts

Here will be two script. You need to execute **install_pyenv.sh** first then **odoo.sh**. Execution of install_pyenv.sh will install pyenv if your system doesn't have it. This is basically used to manage multiple version of python.odoo.sh will install odoo 11(python 3.7) and odoo 16(python 3.10). 

## Setting up Pycharm

**Step 1** Open the project directory.

**Step 2**
From File > Setting > project > Interpreter > add virtual environments
edit configuration.
