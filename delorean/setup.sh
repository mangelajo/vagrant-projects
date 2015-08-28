#!/bin/sh

# Setup yum repos
sudo yum -y install http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo curl https://copr.fedoraproject.org/coprs/jruzicka/rdopkg/repo/epel-7/jruzicka-rdopkg-epel-7.repo -o /etc/yum.repos.d/jruzicka-rdopkg-epel-7.repo

# Update all packages
sudo yum -y update

# Install dependencies needed by delorean
sudo yum -y install docker-io git createrepo python-virtualenv selinux-policy rdopkg

# some more python C build deps
sudo yum -y install gcc

# Fetch delorean
git clone https://github.com/openstack-packages/delorean.git

# Setup docker
sudo groupadd docker
sudo usermod -a -G docker $USER
chcon -t docker_exec_t delorean/scripts/*
sudo systemctl start docker

pushd delorean

# Prepare virtualenv for delorean
virtualenv ../delorean-venv
. ../delorean-venv/bin/activate
python setup.py develop

# Build docker image
sudo su -l $USER ./delorean/scripts/create_build_image.sh

popd

# always build dev packages
echo "alias delorean='delorean --config-file projects.ini --local --dev --package-name'" >> .bashrc

# Enter the delorean venv on login
echo "cd delorean" >> .bashrc
echo ". ../delorean-venv/bin/activate" >> .bashrc
