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
  -o    Do not install South (migrations)
  -g    Do not initialize Git repository
  -d    Skip development dependency installation
  -n    Skip virtualenv creation
  -s    Skip project creation
  -c    Use custom settings file
  -b    Add bootstrap.sh
  -h    Show usage (this message)'
}

# Default settings
USE_MYSQL=0
USE_SOUTH=1
USE_GIT=1
USE_DEV=1
USE_VENV=1
USE_DYNAMIC=0
USE_PROJECT=1
USE_BOOTSTRAP=0

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
		b)
			USE_BOOTSTRAP=1
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

VENV_PATH=$1
PROJ_NAME=$2

if [ -e $VENV_PATH ]
then
	err "$VENV_PATH already exists. Aborting."
	exit 1;
fi

# Create the virtualenv/git root directory
mkdir -p $VENV_PATH

if [ "$USE_VENV" == "1" ]
then
	msg "Creating virtualenv in $VENV_PATH"
	which virtualenv >> /dev/null || { err "ERROR: No virtualenv command. Aborting."; exit 2; }
	virtualenv --no-site-packages $VENV_PATH
fi

cd $VENV_PATH

if [ "$USE_VENV" == "1" ]
then
	msg "Enabling virtualenv environment"
	source ./bin/activate
fi

msg "Generating requirements.txt"
echo 'https://www.djangoproject.com/download/1.5a1/tarball/#egg=django' >> requirements.txt

if [ "$USE_SOUTH" == "1" ]
then
	echo "South==0.7.6" >> requirements.txt
fi

if [ "$USE_MYSQL" == "1" ]
then
	msg "Adding MySQL to requirements.txt"
	echo "MySQL-python==1.2.4c1" >> requirements.txt
fi

msg "Installing runtime requirements to $VENV_PATH"
pip install -r requirements.txt || { err "ERROR: Failed to install Django. Aborting."; exit 3; }

if [ "$USE_DEV" == "1" ]
then
	msg "Generating dev_requirements.txt"
	echo "ipython==0.13.1" >> dev_requirements.txt
	echo "mock==1.0.0" >> dev_requirements.txt
	echo "coverage==3.5.3" >> dev_requirements.txt

	msg "Installing development tools"
	pip install -r dev_requirements.txt || { err "ERROR: Failed to install development requirements. Aborting."; exit 4; }
fi

if [ "$USE_PROJECT" == "1" ]
then
	msg "Creating new Django project $PROJ_NAME in $VENV_PATH/src"
	django-admin.py startproject $PROJ_NAME || { err "ERROR: Could not start project. Aborting."; exit 5; }
	mv $PROJ_NAME src
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
echo "lib" >> .gitignore
echo "share" >> .gitignore
echo "include" >> .gitignore
echo "bin" >> .gitignore
echo "*.sublime-project" >> .gitignore
echo "*.sublme-workspace" >> .gitignore

if [ "$USE_BOOTSTRAP" == "1" ]
then
	msg "Creating bootstrap script"
	echo "#!/bin/bash" > bootstrap.sh
	echo "set -e" >> bootstrap.sh

	if [ "$USE_VENV" == "1" ]
	then
		echo 'if [ ! -e bin/activate ]; then' >> bootstrap.sh
		echo "  virtualenv --no-site-packages ." >> bootstrap.sh
		echo "fi" >> bootstrap.sh
	fi

	echo "source ./bin/activate || true" >> bootstrap.sh

	echo 'pip install -r requirements.txt || { echo "Could not install dependencies. Aborting."; exit 1; }' >> bootstrap.sh

	echo 'if [ -e "dev_dependencies.txt" ]; then' >> bootstrap.sh
	echo '  pip install -r dev_dependencies.txt || { echo "Could not install dev dependencies. Aborting."; exit 2; }' >> bootstrap.sh
	echo 'fi' >> bootstrap.sh

	echo "echo Bootstrap finished. You can activate your virtualenv now." >> bootstrap.sh
	chmod u+x bootstrap.sh
fi

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
	echo "    cd $VENV_PATH/"
	echo "    source ./bin/activate"
	echo
	echo "To deactivate the virtualenv, just type:"
	echo
	echo "    deactivate"
	echo
	echo "============================================================="
	echo
fi
