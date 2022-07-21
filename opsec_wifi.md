Here is a list of stuff with wifi that leads to deanonymization and some other trivia on information leaks with this technology. No wifi hacking tho.

All of those attacks only work if your adversary is in range of your wifi. It can be extended with directional antennas, LNAs and all of this is applying to management packets 3. Those are modulated differently to allow for more range at the cost of bandwidth compared to normal data packets.
Mac Addresses

Your wifi card has a permanent hardware serial number that is used as its address on OSI layer 2, the MAC address. It is send unencrypted with every packet and can be read by anyone in range.
This number is of the following format: “FF:FF:FF:AA:AA:AA”,
where the first 3x2 hex digits are the manufacturers prefix, and the last part the unique identifier within that address space.

Here 12 is a list of all manufacturer prefixes.

If you see a MAC address that is for example 00:20:91:AB:0C:13 you can figure out that this wifi card was build by the National Security Agency.

Everybody in range can passively log MAC addresses with minimal ($2) hardware.
Mitigations

Turn on MAC randomization and hostname randomization 14. I wrote a setup script if somebody wants to copy my (very simple and auditable) bashcode into dom0.

Caveat! Some wifi firmwares are shitty. You can change your MAC address in software, but some chipsets will answer to packets that are addressed at their real MAC address, enabling an adversary to perform an active confirmation attack.
Wifi probes

Wifi probes are a bitch 26, so you probably want to mitigate those.

The APs (the thing that makes your wifi network) does send out beacon frames periodically, basically saying “Hi, i am network_a!”. This is enough for your devices to connect to it, but to speed up this process and to aid in roaming wifi probes are used.

Those are unencrypted packets send out by your devices whenever wifi is enabled to interrogate every known APs.

You wifi cards constantly sends out “hey home network, are you there? Hey network of my mate, are you there?” for every network you where connected at one time, resulting in a pretty unique used AP list that leaks astonishing metadata like where you where on vacation in some scenarios (“trump hotel guest wifi”) and so on… More a threat to smartphones, but of course also applies to laptops.

Wifi probe fingerprinters are in active deployment by corpos to track if customers return to their store and measure engagement by deploying one on billboards and one in the store… Those things are cheap ($2).
Mitigation

Only activate wifi if you really need it.
Delete old networks you won’t use anymore.
In qubes you could create one sys-wifi-networkname that is used as the netvm for sys-net for every network you connect and only start the one you want, or selectively only expose the configuration of needed networks to your sys-net dynamically.
Hardware imperfections

If your adversary is technically a bit more skilled, ones wifi card can be uniquely finerprinted by its hardware imperfections 21. Despite the fanciness of thid attack the needed hardware has gotten quite cheap (~20$). I am not aware of ready to go open source solutions for this attack If you are: Please send me a link!
Mitigations

None.

As you cannot mitigate your hardware imperfections in software, the only way to stay “anonymous” is to simply buy more hardware.

Assume that every wifi device can be uniquely identified by an skilled and motivated adversary.

You can compartmentalize with hardware, like use only one physical wifi device for one single network, this would at least make your adversary unable to link together different networks you use.

You adversary will still be able to recognize that the same device is connected to the same network again, but there is nothing one can do about that that would scale good enough to be practical, but to not use wifi.
Other stuff

There is much wrong with wifi, i will not go into the attacks on the crypto here.

But even without attacking the crypto an passive adversary can monitor network traffic metadata (timings, size of packets) and leverage that knowledge with other deanonymization techniques.

Oh and you can look through walls 48 with wifi. Pretty neat. LE has this in active deployment for years now.
Threat model is everything

This all may sound scary, and arguably it is. Assuming the most powerful adversary is a common mistake new ppl make in OPSEC so carefully evaluate what attacks your specific adversary is capable of/willing to execute.

Here is my assesment:
Mac address deanonymication: Active deployment, cheap easy. Everybody can do this and corpos do this already.

Wifi probe deanonymization: Active deployment, cheap, easy. Everybody can do this and corpos do this already.

Hardware imperfections: No known deployment in an industrial setting. I would say this is more private investigator and higher adversary stuff.

Looking through walls:
Batshit sci-fi crazy. LE stuff. If you have an open source project you know of, pls let me know!


Randomize all Ethernet and Wifi connections

These steps should be done inside a template to be used to create a NetVM as it relies on creating a config file that would otherwise be deleted after a reboot due to the nature of AppVMs.

Write the settings to a new file in the /etc/NetworkManager/conf.d/ directory, such as 00-macrandomize.conf. The following example enables Wifi and Ethernet MAC address randomization while scanning (not connected), and uses a randomly generated but persistent MAC address for each individual Wifi and Ethernet connection profile.

[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=stable
ethernet.cloned-mac-address=stable
connection.stable-id=${CONNECTION}/${BOOT}
#use random IPv6 addresses per session / don't leak MAC via IPv6 (cf. RFC 4941):
ipv6.ip6-privacy=2

    stable in combination with ${CONNECTION}/${BOOT} generates a random address that persists until reboot.
    random generates a random address each time a link goes up.

To see all the available configuration options, refer to the man page: man nm-settings

Next, create a new NetVM using the edited template and assign network devices to it.

Finally, shutdown all VMs and change the settings of sys-firewall, etc. to use the new NetVM.

You can check the MAC address currently in use by looking at the status pages of your router device(s), or inside the NetVM with the command sudo ip link show.
Anonymize your hostname

DHCP requests also leak your hostname to your LAN. Since your hostname is usually sys-net, other network users can easily spot that you're using Qubes OS.

Unfortunately NetworkManager currently doesn't provide an option to disable that leak globally (Gnome Bug 768076). However the below alternatives exist.
Prevent hostname sending

NetworkManager can be configured to use dhclient for DHCP requests. dhclient has options to prevent the hostname from being sent. To do that, add a file to your sys-net template (usually the Fedora or Debian base template) named e.g. /etc/NetworkManager/conf.d/dhclient.conf with the following content:

[main]
dhcp=dhclient

Afterwards edit /etc/dhcp/dhclient.conf and remove or comment out the line starting with send host-name.

If you want to decide per connection, NetworkManager also provides an option to not send the hostname:
Edit the saved connection files at /rw/config/NM-system-connections/*.nmconnection and add the dhcp-send-hostname=false line to both the [ipv4] and the [ipv6] section.
Randomize the hostname

Alternatively you may use the following code to assign a random hostname to a VM during each of its startup. Please follow the instructions mentioned in the beginning to properly install it.

#!/bin/bash
set -e -o pipefail
#
# Set a random hostname for a VM session.
#
# Instructions:
# 1. This file must be placed and made executable (owner: root) inside the template VM of your network VM such that it will be run before your hostname is sent over a network.
# In a Fedora template, use `/etc/NetworkManager/dispatcher.d/pre-up.d/00_hostname`.
# In a Debian template, use `/etc/network/if-pre-up.d/00_hostname`.
# 2. Execute `sudo touch /etc/hosts.lock` inside the template VM of your network VM.
# 3. Execute inside your network VM:
#  `sudo bash -c 'mkdir -p /rw/config/protected-files.d/ && echo -e "/etc/hosts\n/etc/hostname" > /rw/config/protected-files.d/protect_hostname.txt'`


#NOTE: mv is atomic on most systems
if [ -f "/rw/config/protected-files.d/protect_hostname.txt" ] && rand="$RANDOM" && mv "/etc/hosts.lock" "/etc/hosts.lock.$rand" ; then
	name="PC-$rand"
	echo "$name" > /etc/hostname
	hostname "$name"
	#NOTE: NetworkManager may set it again after us based on DHCP or /etc/hostname, cf. `man NetworkManager.conf` @hostname-mode
	
	#from /usr/lib/qubes/init/qubes-early-vm-config.sh
	if [ -e /etc/debian_version ]; then
            ipv4_localhost_re="127\.0\.1\.1"
        else
            ipv4_localhost_re="127\.0\.0\.1"
        fi
        sed -i "s/^\($ipv4_localhost_re\(\s.*\)*\s\).*$/\1${name}/" /etc/hosts
        sed -i "s/^\(::1\(\s.*\)*\s\).*$/\1${name}/" /etc/hosts
fi
exit 0

Assuming that you're using sys-net as your network VM, your sys-net hostname should now be PC-[number] with a different [number] each time your sys-net is started.

Please note that the above script should not be added to /rw/config/rc.local) as that is executed only after the network fully started.
