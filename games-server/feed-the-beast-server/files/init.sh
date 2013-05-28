#!/sbin/runscript
# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

extra_started_commands="console"

MULTIVERSE="${SVCNAME#*.}"
[[ "${SVCNAME}" == "${MULTIVERSE}" ]] && MULTIVERSE="main"

LOCK="/var/lib/minecraft/${MULTIVERSE}/server.log.lck"
PID="/var/run/minecraft/${MULTIVERSE}.pid"
SOCKET="/tmp/tmux-minecraft-${MULTIVERSE}"

depend() {
	need net
}

start() {
	local SERVER="${SVCNAME%%.*}"
	local EXE="/usr/games/bin/${SERVER}"

	ebegin "Starting Minecraft multiverse \"${MULTIVERSE}\" using ${SERVER}"

	if [[ ! -x "${EXE}" ]]; then
		eend 1 "${SERVER} was not found. Did you install it?"
		return 1
	fi

	if fuser -s "${LOCK}" &> /dev/null; then
		eend 1 "This multiverse appears to be in use, maybe by another server?"
		return 1
	fi

	local CMD="umask 027 && '${EXE}' '${MULTIVERSE}'"
	su -c "/usr/bin/tmux -S '${SOCKET}' new-session -n 'minecraft-${MULTIVERSE}' -d \"${CMD}\"" "@GAMES_USER_DED@"

	if ewaitfile 15 "${LOCK}" && local FUSER=$(fuser "${LOCK}" 2> /dev/null); then
		echo "${FUSER}" > "${PID}"
		eend 0
	else
		eend 1
	fi
}

stop() {
	ebegin "Stopping Minecraft multiverse \"${MULTIVERSE}\""

	# tmux will automatically terminate when the server does.
	start-stop-daemon -K -p "${PID}"
	rm -f "${SOCKET}"

	eend $?
}

console() {
	exec /usr/bin/tmux -S "${SOCKET}" attach-session
}

backup() {
        /usr/bin/tmux -S "${SOCKET}" send-keys 'say Server backup starting...' C-m
        /usr/bin/tmux -S "${SOCKET}" send-keys 'save-off' C-m
        /usr/bin/tmux -S "${SOCKET}" send-keys 'save-all' C-m
        sync

        cd "/var/lib/minecraft/${MULTIVERSE}/"
        local BACKUP="/var/lib/minecraft/${MULTIVERSE}/backup/${MULTIVERSE}-`date "+%Y%m%d-%H%M"`.tar.bz2"
        tar -jcpf "${BACKUP}" --exclude='backup' .
        chown "@GAMES_USER_DED@":"@GAMES_USER_DED@" "${BACKUP}"
        cd -

        /usr/bin/tmux -S "${SOCKET}" send-keys 'save-on' C-m
        /usr/bin/tmux -S "${SOCKET}" send-keys 'say Server backup completed.' C-m
}

