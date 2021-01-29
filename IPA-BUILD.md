# IPA mfsBSD

## Description
This repo is a fork to the mfsBSD with additional configurations and scripts that can build mfsBSD with openstack ironic python agent. An mfsBSD image built from this repo can be used to PXE boot virtual OneFS clusters.

You need a FreeBSD machine or VM in order to build. Make sure that you have the FreeBSD ports and source installed on the machine.

## Make ironic-python-agent and ironic-lib ports. Place them in a local package repo

1. Clone PowerScale ironic-python-agent
```
git clone git@github.com:Dell-EMC-Cloud/ironic-python-agent.git
```

1. Checkout the powerscale branch

```
cd ironic-python-agent
git checkout powerscale
```

1. Build the ports

```
cd py-ironic-lib; make makesum; make package

cd py-ironic-python-agent; make makesum; PBR_VERSION=6.5.0 make package
```

1. Create a local package repo

```
sudo mkdir -p /usr/local/etc/pkg/repos
sudo mkdir -p /usr/local/etc/pkg/packages

cd /usr/local/etc/pkg/repos
- create a file local.conf with
sudo cat > local.conf << EOF
local: {
    url: file:///usr/local/etc/pkg/packages
    enabled: yes
}
EOF
```

1. Copy py-ironic-python-agent and py-ironic-lib packages

```
cd <root dir of ironic-python-agent>
sudo cp py-ironic-lib/work-py37/pkg/py37-ironic-lib-4.5.0.txz /usr/local/etc/pkg/packages
sudo cp py-ironic-python-agent/work-py37/pkg/py37-ironic-python-agent-6.5.0.txz /usr/local/etc/pkg/packages
```

1. Generate packages for the local repo

```
sudo pkg repo /usr/local/etc/pkg/packages
sudo pkg update
```

## Build IPA mfsBSD

```
cd <root of IPA mfsBSD repo>
git checkout ipa
ci/ci.sh -b prepare
make BASE=/tmp/freebsd
```

To build an iso:

```
make iso BASE=/tmp/freebsd
```

## Change ironic-python-agent code
Any time that its code is changed, the ports and IPA mfsBSD need to be rebuilt.

1. Check in your change

1. Push your change up

1. Find the commit hash with `git log`

1. Update the GH_TAGNAME with the commit hash in the Makefile of py-ironic-python-agent

1. Build the py-ironic-python-agent port as described earlier

1. Copy the resulting package to the local package repo as described earlier

1. Build IPA mfsBSD as described earlier. You'd need to remove its existing work directory and the existing image in order to rebuild it. The work directory is called `work` in the github root directory.
