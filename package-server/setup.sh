#!/bin/bash

echo "daemon off;" >> /etc/nginx/nginx.conf
mkdir -p /etc/nginx/ssl
echo "server_names_hash_bucket_size 64;" >/etc/nginx/conf.d/server_names_hash_bucket_size.conf

# Add keys for signing.
gpg --import /pubring.gpg
gpg --allow-secret-key-import --import /secring.gpg

# Make pub.key available.
mkdir -p /var/reprepro
gpg --armor --output /var/reprepro/opendavinci.cse.chalmers.se.gpg.key --export <Your Key ID>

# Remove keys.
rm -f /pubring.gpg /secring.gpg

# Define GPG signing for RPM:
cat <<EOF >/root/.rpmmacros
%_signature gpg
%_gpg_path /root/.gnupg
%_gpg_name <Your Name>
%_gpgbin /usr/bin/gpg
EOF

# Import GPG key in rpm.
rpm --import /RPM-GPG-KEY-developer && rm -f /RPM-GPG-KEY-developer

# Sign rpms.
for i in $(ls /tmp/*rpm); do
    /signrpm.exp $i
    rpm --checksig $i
done

# Configuration for Ubuntu trusty, vivid
mkdir -p /var/reprepro/ubuntu/{conf,dists,indices,logs,pool,project,tmp}

cat <<EOF >/var/reprepro/ubuntu/conf/distributions
Origin: <Your Name> 
Label: <Your Label>
Codename: trusty
Architectures: i386 amd64 armhf
Components: main
Description: <Your Description>
SignWith: <Your Key ID>

Origin: <Your Name>
Label: <Your Label>
Codename: vivid
Architectures: i386 amd64 armhf
Components: main
Description: <Your Description>
SignWith: <Your Key ID>
EOF

cat <<EOF > /var/reprepro/ubuntu/conf/options
ask-passphrase
basedir .
EOF

# Configuration for Ubuntu wily
mkdir -p /var/reprepro/ubuntu-wily/{conf,dists,indices,logs,pool,project,tmp}
cat <<EOF >/var/reprepro/ubuntu-wily/conf/distributions
Origin: <Your Name>
Label: <Your Label>
Codename: wily
Architectures: amd64
Components: main
Description: <Your Description>
SignWith: <Your Key ID>
EOF

cat <<EOF > /var/reprepro/ubuntu-wily/conf/options
ask-passphrase
basedir .
EOF

# Configuration for Debian jessie
mkdir -p /var/reprepro/debian/{conf,dists,indices,logs,pool,project,tmp}
cat /var/reprepro/ubuntu/conf/distributions | sed s/trusty/jessie/ >> /var/reprepro/debian/conf/distributions
cp /var/reprepro/ubuntu/conf/options /var/reprepro/debian/conf/options

# Add .deb for Ubuntu trusty
reprepro --basedir /var/reprepro/ubuntu --ask-passphrase -V includedeb trusty /tmp/*.deb
# Add .deb for Ubuntu vivid
reprepro --basedir /var/reprepro/ubuntu --ask-passphrase -V includedeb vivid /tmp/*.deb
# Add .deb for Ubuntu wily
reprepro --basedir /var/reprepro/ubuntu-wily --ask-passphrase -V includedeb wily /packages/ubuntu_wily/*.deb
# Add .deb for Debian jessie
reprepro --basedir /var/reprepro/debian --ask-passphrase -V includedeb jessie /tmp/*.deb

# Create repository for RPMs.
mkdir -p /var/reprepro/rpm-i686/repo
cp /tmp/*i686*.rpm /var/reprepro/rpm-i686/repo

createrepo /var/reprepro/rpm-i686/repo
gpg -a --detach-sign /var/reprepro/rpm-i686/repo/repodata/repomd.xml
gpg -a --export <Your Key ID> > /var/reprepro/rpm-i686/repo/repodata/repomd.xml.key

cat <<EOF >/var/reprepro/OpenDaVINCI-i686.repo
[<Your Label>]
name=<Your Label> (i686)
type=rpm-md
baseurl=http://opendavinci.cse.chalmers.se/rpm-i686/repo/
gpgcheck=1
gpgkey=http://opendavinci.cse.chalmers.se/rpm-i686/repo/repodata/repomd.xml.key
enabled=1
EOF

mkdir -p /var/reprepro/rpm-x86_64/repo
cp /tmp/*x86_64*.rpm /var/reprepro/rpm-x86_64/repo
createrepo /var/reprepro/rpm-x86_64/repo
gpg -a --detach-sign /var/reprepro/rpm-x86_64/repo/repodata/repomd.xml
gpg -a --export <Your Key ID> > /var/reprepro/rpm-x86_64/repo/repodata/repomd.xml.key

cat <<EOF >/var/reprepro/OpenDaVINCI-x86_64.repo
[<Your Label>]
name=<Your Label> (x86_64)
type=rpm-md
baseurl=http://opendavinci.cse.chalmers.se/rpm-x86_64/repo/
gpgcheck=1
gpgkey=http://opendavinci.cse.chalmers.se/rpm-x86_64/repo/repodata/repomd.xml.key
enabled=1
EOF

mkdir -p /var/reprepro/rpm-armhf/repo
cp /tmp/*armhf*.rpm /var/reprepro/rpm-armhf/repo
createrepo /var/reprepro/rpm-armhf/repo
gpg -a --detach-sign /var/reprepro/rpm-armhf/repo/repodata/repomd.xml
gpg -a --export <Your Key ID> > /var/reprepro/rpm-armhf/repo/repodata/repomd.xml.key

cat <<EOF >/var/reprepro/OpenDaVINCI-armhf.repo
[<Your Label>]
name=<Your Label> (armhf)
type=rpm-md
baseurl=http://opendavinci.cse.chalmers.se/rpm-armhf/repo/
gpgcheck=1
gpgkey=http://opendavinci.cse.chalmers.se/rpm-armhf/repo/repodata/repomd.xml.key
enabled=1
EOF

rm -fr /packages/ubuntu_wily
rm -f /tmp/*.deb /tmp/*.rpm
