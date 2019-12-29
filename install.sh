#!/bin/bash

# exit when any command fails
set -e


# fetch submodules at their latest version
git submodule update --init --recursive --remote

# Install essential dependencies
sudo apt install -y build-essential
sudo apt install -y curl
sudo apt-get install --reinstall python-pkg-resources

# Install Python dependencies
sudo apt install -y python3             # default ubuntu python3.x
sudo apt install -y python3-venv        # support Python virtual environments
sudo apt install -y python3-dev         # for python3.x installs
sudo apt install -y python3-setuptools  # unfortunately required for poetry
# Get the correct Python version
PYTHON3_VERSION=`python3 -c 'import sys; version=sys.version_info[:3]; print("{0}{1}".format(*version))'`

# install Mininet dependencies
sudo apt install -y openvswitch-switch cgroup-bin help2man

# install traffic monitors
sudo apt install -y tcpdump ifstat

# install the traffic generator using Go
if  [[ $1 = "--goben" ]]; then
echo "Building goben traffic generator..."
cd contrib
./install_goben.sh
cd ..
fi

# install the PCC kernel module
if  [[ $1 = "--pcc" ]]; then
make -C contrib/pcc/src/
cp contrib/pcc/src/tcp_pcc.ko dc_gym/topos
fi

# required for traffic adjustment
sudo apt install -y libnl-route-3-dev

# Install pip and virtualenv
# Build the dc_gym
sudo apt install virtualenv
virtualenv -p /usr/bin/python3 venv
. venv/bin/activate
pip install numpy pandas gym seaborn matplotlib gevent opencv-python tensorflow==1.14.0 tensorflow-probability lz4 psutil setproctitle stable-baselines

# compile the traffic control
make -C dc_gym/monitor
make -C dc_gym/control

# install Mininet
cd contrib/mininet
sudo make install PYTHON=$(which python)    # install the Python3 version
cd ../..

# Install the dc_gym locally
#$PIP_VERSION install --upgrade --user dist/*.whl

# Install unresolved Ray runtime dependencies...
sudo apt install -y libsm6 libxext6 libxrender-dev

sudo apt install net-tools
