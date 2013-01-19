#!/bin/bash

set -e # Bail on all errors

txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtrst='\e[0m'    # Text Reset

# Print message
function msg {
	echo -e "$txtylw==>$txtgrn $1$txtrst"
}

function err {
	echo -e "$txtylw==>$txtred $1$txtrst"
}

# Print script usage
function print_help {
	echo '
Usage:
  djangostrap.sh [-mogdnsbh -c FILE] PATH NAME

  PATH - path to virtualenv
  NAME - project name

Options:

  -m    Install MySQL driver
  -p    Install Posgres driver
  -o    Do not install South (migrations)
  -u    Do not install gunicorn (fast WSGI server)
  -g    Do not initialize Git repository
  -d    Skip development dependency installation
  -n    Skip virtualenv creation
  -s    Skip project creation
  -c    Use custom settings file
  -h    Show usage (this message)'
}

# Default settings
USE_MYSQL=0
USE_POSTGRES=0
USE_SOUTH=1
USE_GIT=1
USE_DEV=1
USE_VENV=1
USE_DYNAMIC=0
USE_PROJECT=1
USE_GUNICORN=1

# Parse command line arguments
while getopts mogdnsc:bh OPT; do
	case "$OPT" in
		h)
			print_help
			exit 0
			;;
		m)
			USE_MYSQL=1
			;;
		o)
			USE_SOUTH=0
			;;
    u)
      USE_GUNICORN=0
      ;;
		g)
			USE_GIT=0
			;;
		d)
			USE_DEV=0
			;;
		n)
			USE_VENV=0
			;;
		s)
			USE_PROJECT=0
			;;
		c)
			USE_DYNAMIC=1
			SETTINGS_FILE=$OPTARG
			;;
		\?)
			print_help
			exit 1
			;;
	esac
done

# Let's first remember the path to template settings file
if [ -e "$SETTINGS_FILE" ]
then
    USE_DYNAMIC=1
	SETTINGS_FILE=$(readlink -f "$SETTINGS_FILE")
fi

# We're done parsing options, so remove them from argument array
shift `expr $OPTIND - 1`

# Check that we still have two required arguments
if [ -z "$1" -o -z "$2" ]
then
	err "ERROR: Missing PATH or NAME"
	print_help
	exit 1
fi

PROJ_PATH=$1
PROJ_NAME=$2

if [ ! -d "$WORKON_HOME" ]
then
    err "The environment variable "'$WORKON_HOME'" is not defined"
    exit 1;
fi

if [ -e $PROJ_PATH ]
then
	err "$PROJ_PATH already exists. Aborting."
	exit 1;
fi

if [ "$USE_VENV" == "1" ]
then
	msg "Creating virtualenv $PROJ_NAME"
    which virtualenv >> /dev/null || { err "ERROR: No virtualenvwrapper. Aborting."; exit 2; }
	virtualenv --no-site-packages "$WORKON_HOME/$PROJ_NAME"
    source "$WORKON_HOME/$PROJ_NAME/bin/activate"
fi

# Create the project root

msg "Creating project directory in $PROJ_PATH"
mkdir -p $PROJ_PATH
cd $PROJ_PATH

msg "Generating empty README.rst"
touch README.rst

msg "Creating documentation directory"
mkdir doc

msg "Generating requirements.txt"
echo 'https://www.djangoproject.com/download/1.5c1/tarball/#egg=django' >> requirements.txt

if [ "$USE_SOUTH" == "1" ]
then
	echo "South==0.7.6" >> requirements.txt
fi

if [ "$USE_GUNICORN" == "1" ]
then
  msg "Adding gunicorn to requirements.txt"
  echo "gunicorn==0.16.1" >> requirements.txt
fi

if [ "$USE_MYSQL" == "1" ]
then
	msg "Adding MySQL to requirements.txt"
	echo "MySQL-python==1.2.4c1" >> requirements.txt
fi

if [ "$USE_POSTGRES" == "1" ]
then
    msg "Adding Posgres to requirements.txt"
    echo "psycopg2==2.4.6" >> requirements.txt
fi

msg "Installing runtime requirements"
pip install -r requirements.txt || { err "ERROR: Failed to install dependecies. Aborting."; exit 3; }

if [ "$USE_DEV" == "1" ]
then
	msg "Generating dev_requirements.txt"
	echo "ipython>=0.13.1" >> dev_requirements.txt
	echo "mock>=1.0.0" >> dev_requirements.txt
	echo "coverage>=3.5.3" >> dev_requirements.txt
    echo "django-webtest>=1.5.5" >> dev_requirements.txt
    echo "django-discover-runner>=0.2.1" >> dev_requirements.txt
    echo "webtest>=1.4.2" >> dev_requirements.txt
    echo "pyquery>=1.2.2" >> dev_requirements.txt
    echo "factory_boy>=1.2.0" >> dev_requirements.txt

	msg "Installing development tools"
	pip install -r dev_requirements.txt || { err "ERROR: Failed to install development requirements. Aborting."; exit 4; }
fi

if [ "$USE_PROJECT" == "1" ]
then
    mkdir src || { err "ERROR: Failed to crate source directory at $PROJ_PATH/src"; exit 5; }
	msg "Creating new Django project $PROJ_NAME in $PROJ_PATH/src"
	django-admin.py startproject "$PROJ_NAME" src || { err "ERROR: Could not start project. Aborting."; exit 5; }
fi

if [ "$USE_DYNAMIC" == "1" ]
then
	if [ ! -e $SETTINGS_FILE ]
	then
		err "Could not find $SETTINGS_FILE. Skipping custom settings file."
	else
		msg "Creating dynamic settings file"
		cat $SETTINGS_FILE | sed "s|@@@|$PROJ_NAME|" > src/$PROJ_NAME/settings.py
	fi
fi

msg "Creating Git ignore file"
echo "*.pyc" >> .gitignore
echo "*.pyo" >> .gitignore
echo "*.swp" >> .gitignore
echo "*.swo" >> .gitignore
echo "*~" >> .gitignore
echo "*.db" >> .gitignore

if [ "$USE_GIT" == "1" ]
then
	msg "Initializing a git repository and committing fresh repository"
	git init || { err "ERROR: Could not initalize Git repository. Aborting."; exit 6; }
	git add .
	git ci -m "Just created $PROJ_NAME project"
fi

echo
msg "All done"
echo

if [ "$USE_VENV" == "1" ]
then
	echo "============================================================="
	echo
	echo "IMPORTANT:"
	echo
	echo "You have to enable the virtualenv when you want to develop."
	echo "Simly do this:"
	echo
	echo "    workon $PROJ_NAME"
	echo
	echo "To deactivate the virtualenv, just type:"
	echo
	echo "    deactivate"
	echo
	echo "============================================================="
	echo
fi
