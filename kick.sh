#!/bin/bash
set -x

function delete {
  disk="/var/lib/libvirt/filesystems/${name}.qcow2"
  virsh destroy ${name}
  virsh undefine ${name}
  rm ${disk}
}


#virt-install -n centos7 -r 4096 --vcpus=2 --os-type linux --os-variant=rhel7 --network=default --nographics --location='http://ftp.hosteurope.de/mirror/centos.org/7/os/x86_64/' --initrd-inject=./centos7x_kvm.ks --extra-args='ks=file:/centos7x_kvm.ks text console=tty0 console=ttyS0,115200n8 serial' --disk="/tmp/centos7x.qcow2" --hvm  --connect=qemu:///system 

function install {

  #name="centos7"
  echo "name: $name"
  disk="/var/lib/libvirt/filesystems/${name}.qcow2"
  echo "disk: $disk"
  kickfile="./centos7x_kvm.ks"
  sed -i "s/network --device eth0 --bootproto dhcp --hostname.*/network --device eth0 --bootproto dhcp --hostname ${name}/g" ${kickfile}
  grep "network --device" ${kickfile}
  echo "location: $location"

  if [[ ! -f $disk ]]
  then
    echo "qemu-img create -f qcow2 ${disk} 20G"
    qemu-img create -f qcow2 ${disk} 20G
  fi


virt-install -n ${name} -r 4096 --vcpus=2 --os-type linux --os-variant=rhel7 --network=default --nographics --location=${location} --initrd-inject=./centos7x_kvm.ks --extra-args='ks=file:/centos7x_kvm.ks text console=tty0 console=ttyS0,115200n8 serial' --disk=${disk} --hvm 

#--connect=qemu:///system

}

while getopts 'doln:' opt;
  do
    case $opt in
      n) name=$OPTARG
        ;;
      o)
        location="http://ftp.hosteurope.de/mirror/centos.org/7/os/x86_64/"
	#location="http://ftp.halifax.rwth-aachen.de/centos/8/BaseOS/x86_64/kickstart/"
	install
	;;
      l)
	#location="/var/lib/libvirt/images/CentOS-8-x86_64-1905-dvd1.iso"
	location="/var/lib/libvirt/images/CentOS-7-x86_64-Everything-1708.iso"
        install
	;;
      d)
        delete
        ;;
    esac
  done
