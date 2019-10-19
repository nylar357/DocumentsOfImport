# DocumentsOfImport
extremely useful documents written by real professionals


fixing etherape for BackBox:
~sudo apt-get install libgnomeui-0:amd64

bettercap installation 

Installation

bettercap supports GNU/Linux, BSD, Android, Apple macOS and the Microsoft Windows operating systems - depending if you want to install the latest stable release or the bleeding edge from the GitHub repository, you have several choices.
Precompiled Binaries

For every new release, we distribute bettercap’s precompiled binaries. In order to be able to use them, you’ll need the following dependencies on your system:

    libpcap
    libusb-1.0-0 (required by the HID module)
    libnetfilter-queue (on Linux only, required by the packet.proxy module)

Using Docker

BetterCAP is containerized using Alpine Linux - a security-oriented, lightweight Linux distribution based on musl libc and busybox. The resulting Docker image is relatively small and easy to manage the dependencies. Since it is using a multi-stage build, a Docker version greater than 17.05 is required.

To pull latest stable version of the image:

docker pull bettercap/bettercap

To pull latest source code build of the image:

docker pull bettercap/dev

To run:

docker run -it --privileged --net=host bettercap/bettercap -h

Compiling from Sources

In order to compile bettercap from sources, make sure that:

    You have a correctly configured Go >= 1.8 environment.
    $GOPATH is defined and $GOPATH/bin is in $PATH.

You’ll also need to install the dependencies:

    build-essential
    libpcap-dev
    libusb-1.0-0-dev (required by the HID module)
    libnetfilter-queue-dev (on Linux only, required by the packet.proxy module)

Once you’ve met this conditions, you can run the following commands to compile and install bettercap in /usr/local/bin/bettercap:

go get github.com/bettercap/bettercap
cd $GOPATH/src/github.com/bettercap/bettercap
make build 
sudo make install

Compiling on Android
Termux Method

This procedure and bettercap itself require a rooted device.

Install Termux and from its prompt type:

pkg install root-repo
pkg install golang git libpcap-dev libusb-dev

There’s a golang bug in termux about some hardcoded path, the fix is ugly but it works:

sudo su
mount -o rw,remount /
mkdir -p /home/builder/.termux-build/_cache/18-arm-21-v2/bin/
ln -s `which pkg-config` /home/builder/.termux-build/_cache/18-arm-21-v2/bin/arm-linux-androideabi-pkg-config

Linux Deploy Method

Install Linux Deploy, JuiceSSH, in Linux Deploy install kalilinux_arm (u need the piggy helper and enable the SSH) and type:

sudo apt update
sudo apt install golang git build-essential libpcap-dev libusb-1.0-0-dev libnetfilter-queue-dev

You can now proceed with the compilation:

go get -u github.com/bettercap/bettercap

Once the build process is concluded, the binary will be located in go/bin/bettercap.
