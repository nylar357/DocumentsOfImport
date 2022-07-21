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
