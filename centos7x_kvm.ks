text
skipx
install
### url parameter can be taken for online installations
###url --url=http://ftp.hosteurope.de/mirror/centos.org/7/os/x86_64/
lang en_US
keyboard de
network --device eth0 --bootproto dhcp --hostname cent8
auth --useshadow --enablemd5

### Encryption of root password
### Password can be generated with openssl passwd -1
rootpw --iscrypted XXXXXX

selinux --enforcing

firewall --enabled --ssh --http

timezone Europe/Berlin --isUtc

### Generation of password hash is possible with command:
### grub2-mkpasswd-pbkdf2
bootloader --location=mbr --boot-drive=vda --iscrypted --password=XXXXX

zerombr
firstboot --disable
reboot
logging --level=info

clearpart --all --initlabel

part /boot --fstype="xfs" --ondisk=vda --size=512
part pv.100 --fstype="lvmpv" --ondisk=vda --size=1000 --grow
volgroup centosvg --pesize=4096 pv.100
logvol swap --size=2048 --name=swaplv --vgname=centosvg
logvol / --fstype="xfs" --size=5120 --name=rootlv --vgname=centosvg
logvol /var --fstype="xfs" --size=1536 --name=varlv --vgname=centosvg
logvol /var/log --fstype="xfs" --size=1024 --name=var_loglv --vgname=centosvg
logvol /var/tmp --fstype="xfs" --size=2048 --name=var_tmplv --vgname=centosvg
logvol /opt --fstype="xfs" --size=2048 --name=optlv --vgname=centosvg
logvol /home --fstype="xfs" --size=10 --grow --name=homelv --vgname=centosvg

%packages
@base
acpid
nmap-ncat
telnet
vim-enhanced
git
httpd
vsftpd
samba
samba-client
samba-common
nfs-utils
mc
deltarpm
%end

%post
(
HOSTF=$(hostname -f)
HOST=$(hostname -s)

echo "FORWARD_IPV4=no" >> /etc/sysconfig/network
echo "IPV6INIT=no" >> /etc/sysconfig/network
echo "IPV6_AUTOCONF=no" >> /etc/sysconfig/network
echo "NOZEROCONF=yes" >> /etc/sysconfig/network
echo "export TERM=xterm" >> /root/.bashrc
echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf

hostnamectl set-hostname ${HOSTF}
hostnamectl set-hostname --transient ${HOSTF}

cat > /etc/resolv.conf << EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

sytemctl enable acpid
yum update -y

)2>&1 > /root/inst.log
%end
