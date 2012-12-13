# Django settings for @@@ project

import os
import re
from os.path import dirname, realpath, join

PROJECT_ROOT = dirname(realpath(__file__))

DEBUG = False if os.environ.get('LIVE') == '1' else True
TEMPLATE_DEBUG = DEBUG

ADMINS = []

admins = os.environ.get('ADMINS', '').split(',')
admin_re = re.compile(r'^([a-z]+(?: [a-z]+)?) ?<([^>]+)>$', re.IGNORECASE)
for admin in admins:
    matches = admin_re.match(admin)
    if matches:
        ADMINS.append((matches.groups()[0], matches.groups()[1]))

MANAGERS = ADMINS

DATABASES = {
    'default': {
        'ENGINE': os.environ.get('DB_ENGINE', 'django.db.backends.sqlite3'),
        'NAME': os.environ.get('DB_NAME', '%s/@@@.db' % PROJECT_ROOT),
        'USER': os.environ.get('DB_USER', ''),
        'PASSWORD': os.environ.get('DB_PASSWORD', ''),
        'HOST': os.environ.get('DB_HOST', ''),
        'PORT': os.environ.get('DB_PORT', ''),
    },
}

TIME_ZONE = os.environ.get('TIME_ZONE', 'America/Chicago')

LANGUAGE_CODE = 'en-us'

SITE_ID = 1

USE_I18N = True

USE_L10N = True

USE_TZ = True

MEDIA_ROOT = os.environ.get('MEDIA_ROOT', join(PROJECT_ROOT, 'uploads/'))

MEDIA_URL = '/media/'

STATIC_ROOT = os.environ.get('STATIC_ROOT', join(PROJECT_ROOT, 'static/'))

STATIC_URL = '/static/'

STATICFILES_DIRS = (
    join(dirname(PROJECT_ROOT), 'static'),
)

STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
#    'django.contrib.staticfiles.finders.DefaultStorageFinder',
)

SECRET_KEY = os.environ.get('SECRET_KEY') or '!%akukes3hlcl!n-_m(r(!)8pw!o_p#4'
'0a3j5(j4+xj$u6%5ln'

TEMPLATE_LOADERS = (
    'django.template.loaders.filesystem.Loader',
    'django.template.loaders.app_directories.Loader',
#     'django.template.loaders.eggs.Loader',
)

MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    # 'django.middleware.clickjacking.XFrameOptionsMiddleware',
)

TEMPLATE_CONTEXT_PROCESSORS =  (
    'django.contrib.auth.context_processors.auth',
    'django.core.context_processors.debug',
    'django.core.context_processors.i18n',
    'django.core.context_processors.media',
    'django.core.context_processors.static',
    'django.core.context_processors.tz',
    'django.contrib.messages.context_processors.messages',
    'django.core.context_processors.csrf',
    'django.core.context_processors.request',
)

ROOT_URLCONF = '@@@.urls'

# Python dotted path to the WSGI application used by Django's runserver.
WSGI_APPLICATION = '@@@.wsgi.application'

TEMPLATE_DIRS = (
    '%s/templates' % PROJECT_ROOT,
)

INSTALLED_APPS = (
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    #'django.contrib.admin',
    #'django.contrib.admindocs',
    #'django.contrib.humanize',
    #'south',
    #'require',
    #'bootstrap',
    #'crispyforms',
)

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'filters': {
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse'
        }
    },
    'handlers': {
        'mail_admins': {
            'level': 'ERROR',
            'filters': ['require_debug_false'],
            'class': 'django.utils.log.AdminEmailHandler'
        }
    },
    'loggers': {
        'django.request': {
            'handlers': ['mail_admins'],
            'level': 'ERROR',
            'propagate': True,
        },
    }
}

# Test runner configuration
TEST_RUNNER='discover_runner.DiscoverRunner'
TEST_DISCOVER_TOP_LEVEL = dirname(dirname(__file__))
TEST_DISCOVER_ROOT = join(TEST_DISCOVER_TOP_LEVEL, 'tests')

# Email configuration
if os.environ.get('EMAIL_HOST'):
    EMAIL_HOST = os.environ.get('EMAIL_HOST', 'localhost')
    EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER', '')
    EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD', '')
    EMAIL_PORT = int(os.environ.get('EMAIL_PORT', '25'))
    EMAIL_SUBJECT_PREFIX = os.environ.get('EMAIL_SUBJECT_PREFIX', '')
    EMAIL_USE_TLS = os.environ.get('EMAIL_USE_TLS', '0') == '1'
