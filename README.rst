===========
djangostrap
===========

djangostrap is a BASH script that creates a Django project inside virtualenv
with Git scm.

While the script is fairly flexible, it follows the routine that I use day to
day, so it might not fit every use case scenario.

Changelog
=========

djangostrap has no formal releses.

2013-01-19
----------

I have modified the script havily to support a workflow that takes advantage of
virtualenvwrapper. It does not *require* virtualenvwrapper itself, but it
assumes you are using it.

Django has been updated to 1.5 RC1 now.

Finally, Postgres has become a new option in djangostrap. You can install
Posgres driver by using the ``-p`` switch.

Before running
==============

Before you run this script on distros like Ubuntu, please make sure build tools
are installed, and if you want to install development dependencies as well
(default), also install `libxml2-dev` and `libxslt-dev` package. So by default,
you should first do the following::

    sudo apt-get install build-essential libxml2-dev libxslt-dev

If you are not using virtualenvwrapper, make sure you have ``$WORKON_HOME``
environment variable which points to whever you want to create your virtual
environments. If this variable is unset, the script will not work.

Basic usage
===========

For complete instructions on usage, simply execute the script with no
arguments.

Typically, djangostrap is used like this::

    ./djangostrap.sh -c /path/to/settings_template.py project.git project_name

``project.git`` is the directory which is your git repository root.
``project_name`` is the name of the Django project package.

By supplying the ``-c`` switch, we can use a settings module template instead
of the default settings module generated by ``django-admin``.

The ``dev_requirements.txt`` contains a list of packages that are useful for
testing your apps.

Typically, the directory structure created looks like this::

    project.git/
      |-.git/
      |-src/
      |   |-project_name/
      |   \-manage.py
      |-.gitignore
      |-requirements.txt
      \-dev_requirements.txt

If you haven't used virtualenvwrapper before, you should know that all virtual
environments are created in ``~/.virtualenvs``, and they are not part of the
project tree. Your virtualenv is named the same as your project, so be sure
to pick a unique name each time. If you want to know what virtualenvs you have
already created, run the following command::

    workon

To activate your newly created virtualenv, you can type::

    ``workon project_name``

Note about virtualenvwrapper
============================

This script does *not* use virtualenvwrapper itself. For some reason,
virtualenvwrapper tools cannot be used inside shell scripts, so this script
will call virtualenv directly to create the vritualenvs for you. However, it
does use the ``$WORKON_HOME`` variable which is usually associated with
virtualenvwrapper.

Settings template
=================

Settings template supplied with djangostraps assumes that you want to control
the production and development settings using environment variables. While this
is quite convenient in some cases (e.g., Supervisor supports setting
environment variables in its configuration files), it may be cumbersome in
other situations (e.g., you want to run syncdb but then you have to set all the
environment variables related to databases).

I recommend you go through the ``settings_template.py`` file and see if it fits
your needs. Note that inside settings template, the ``@@@`` represents a
placeholder that will be replaced with the value of ``project_name`` (see
`Basic usage`_).

Reporting bugs
==============

Please report bugs to the GitHub `issue tracker`_.

.. _virtualenvwrapper: http://virtualenvwrapper.readthedocs.org/en/latest/
.. _issue tracker: https://github.com/foxbunny/djangostrap/issues
