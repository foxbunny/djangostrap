#!/bin/bash

function print_help {
	echo
	echo "Usage:"
	echo
	echo "  djangostrap.sh PATH NAME"
	echo
	echo "  PATH - path to virtualenv"
	echo "  NAME - project name"
	echo
}

if [ -z "$1" -o -z "$2" ]
then
	echo "ERROR: Missing PATH or NAME"
	print_help
	exit 1
fi

echo "Creating virtualenv in $1"

which virtualenv >> /dev/null || (echo "ERROR: No virtualenv found. Aborting." && exit 2)

virtualenv --no-site-packages $1
cd $1

echo "Enabling virtualenv environment"
source ./bin/activate

echo "Generating requirements.txt"
echo "https://www.djangoproject.com/download/1.5a1/tarball/" >> requirements.txt

echo "Installing Django 1.5a1 to $1"
pip install -r requirements.txt || (echo "ERROR: Failed to install Django. Aborting." && exit 3)

echo "Creating new Django project $2 in $1/src"
django-admin.py startproject $2
mv $2 src

echo "Creating Git ignore file"
echo "*.pyc" >> .gitignore
echo "*.pyo" >> .gitignore
echo "*.swp" >> .gitignore
echo "*.swo" >> .gitignore
echo "*~" >> .gitignore
echo "*.db" >> .gitignore
echo "lib" >> .gitignore
echo "share" >> .gitignore
echo "include" >> .gitignore
echo "bin" >> .gitignore
echo "*.sublime-project" >> .gitignore
echo "*.sublme-workspace" >> .gitignore

echo "Initializing a git repository and committing fresh repository"
git init
git add .
git ci -m "Just created $2 project"

echo
echo "All done"
echo
echo "============================================================="
echo
echo "IMPORTANT:"
echo
echo "You have to enable the virtualenv when you want to develop."
echo "Simly do this:"
echo
echo "    cd $1/"
echo "    source ./bin/activate"
echo
echo "To deactivate the virtualenv, just type:"
echo
echo "    deactivate"
echo
echo "============================================================="
echo
