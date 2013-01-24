gentoo-minecraft-server
=======================

Gentoo overlay for the Minecraft and Tekkit servers

Using this overlay
------------------
Edit /etc/layman/layman.cfg

<pre>overlays  : http://www.gentoo.org/proj/en/overlays/repositories.xml
            https://raw.github.com/WastingBody/gentoo-minecraft-server/master/gentoo-minecraft-server.xml</pre>

Sync your layman overlays

`layman -S`

Add the overlay

`layman -a gentoo-minecraft-server`
