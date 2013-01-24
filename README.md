gentoo-minecraft-server
=======================

Gentoo overlay for the Minecraft and Tekkit servers

Using this overlay

Edit /etc/layman/layman.cfg

overlays  : http://www.gentoo.org/proj/en/overlays/repositories.xml
            https://raw.github.com/WastingBody/gentoo-minecraft-server/master/gentoo-minecraft-server.xml

Sync your layman overlays

layman -S

And finally add overlay

layman -a gentoo-minecraft-server
