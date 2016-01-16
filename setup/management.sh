#!/bin/bash

source setup/functions.sh

echo "Installing Mail-in-a-Box system management daemon..."

# Switching python 2 boto to package manager's, not pypi's.
if [ -f /usr/local/lib/python2.7/dist-packages/boto/__init__.py ]; then hide_output pip uninstall -y boto; fi

# duplicity uses python 2 so we need to use the python 2 package of boto
# build-essential libssl-dev libffi-dev python3-dev: Required to pip install cryptography.
apt_install python3-flask links duplicity python-boto libyaml-dev python3-dnspython python3-dateutil \
	build-essential libssl-dev libffi-dev python3-dev python-pip

# Install other Python packages. The first line is the packages that Josh maintains himself!
hide_output pip3 install --upgrade \
	rtyaml "email_validator>=1.0.0" free_tls_certificates \
	"idna>=2.0.0" "cryptography>=1.0.2" boto psutil
# email_validator is repeated in setup/questions.sh

# Create a backup directory and a random key for encrypting backups.
mkdir -p $STORAGE_ROOT/backup
if [ ! -f $STORAGE_ROOT/backup/secret_key.txt ]; then
	$(umask 077; openssl rand -base64 2048 > $STORAGE_ROOT/backup/secret_key.txt)
fi

# Link the management server daemon into a well known location.
rm -f /usr/local/bin/mailinabox-daemon
ln -s `pwd`/management/daemon.py /usr/local/bin/mailinabox-daemon

# Create an init script to start the management daemon and keep it
# running after a reboot.
rm -f /etc/init.d/mailinabox
ln -s $(pwd)/conf/management-initscript /etc/init.d/mailinabox
hide_output update-rc.d mailinabox defaults

# Remove old files we no longer use.
rm -f /etc/cron.daily/mailinabox-backup
rm -f /etc/cron.daily/mailinabox-statuschecks

# Perform nightly tasks at 3am in system time: take a backup, run
# status checks and email the administrator any changes.

cat > /etc/cron.d/mailinabox-nightly << EOF;
# Mail-in-a-Box --- Do not edit / will be overwritten on update.
# Run nightly tasks: backup, status checks.
0 3 * * *	root	(cd `pwd` && management/daily_tasks.sh)
EOF

# Start the management server.
restart_service mailinabox
