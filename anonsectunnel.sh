#!/bin/bash
export GREEN='\033[1;94m'
export GREEN='\033[1;92m'
export RED='\033[1;91m'
export RESETCOLOR='\033[1;00m'

# Destinations you don't want routed through Tor
TOR_EXCLUDE="192.168.0.0/16 172.16.0.0/12 10.0.0.0/8"

# The UID Tor runs as
# change it if, starting tor, the command 'ps -e | grep tor' returns a different UID
TOR_UID="debian-tor"

# Tor's TransPort
TOR_PORT="9040"


function notify {
	if [ -e /usr/bin/notify-send ]; then
		/usr/bin/notify-send "AnonSec Tunnel" "$1"
	fi
}

export notify


function init {
	echo -e -n " $GREEN*$GREEN killing dangerous applications"
	killall -q chrome dropbox iceweasel skype icedove thbird firefox chromium xchat transmission
	notify "dangerous applications killed"
	
	echo -e -n " $GREEN*$GREEN cleaning some dangerous cache elements"
	bleachbit -c adobe_reader.cache chromium.cache chromium.current_session chromium.history elinks.history emesene.cache epiphany.cache firefox.url_history flash.cache flash.cookies google_chrome.cache google_chrome.history  links2.history opera.cache opera.search_history opera.url_history &> /dev/null
	notify "cache cleaned"
}




function starti2p {
	echo -e -n " $GREEN*$GREEN starting I2P services"
	sudo service i2p start
	sudo cp /etc/resolv.conf /etc/resolv.conf.bak
	sudo cp /etc/wgetrc /etc/wgetrc.bak
	sudo touch /etc/resolv.conf
	sudo touch /etc/wgetrc
	echo -e 'nameserver 127.0.0.1\nnameserver 213.73.91.35\nnameserver 87.118.100.175' > /etc/resolv.conf
	echo -e " $GREEN*$GREEN Modified resolv.conf to use localhost,TOR @ ccc.de(Chaos Computer Club)&German Privacy Foundation"
}

function stopi2p {
	echo -e -n " $GREEN*$GREEN stopping I2P services"
	sudo service i2p stop
	if [ -e /etc/resolv.conf.bak ]; then
		sudo rm /etc/resolv.conf
		sudo rm /etc/wgetrc
		sudo cp /etc/resolv.conf.bak /etc/resolv.conf
		sudo cp /etc/wgetrc.bak /etc/wgetrc
	fi
	notify "I2P daemon stopped"
}



function ip {

	echo -e "\nMy ip is:\n"
	sleep 1
	wget -qO- http://www.icanhazip.com
	echo -e "\n\n----------------------------------------------------------------------"
}

function iceweasel_tor {
	directory="/dev/shm/.mozilla/firefox/profile/a6mpn2rf.default"
	profile="profile_for_tor.tar.gz"

	if [ -d "$directory" ] ; then
		echo -e "\n[$CYAN nfo$RESETCOLOR ]$GREEN Please wait ...$RESETCOLOR\n"
		notify "Please wait ..."
		sleep 0.7
		echo -e "\n[$CYAN nfo$RESETCOLOR ]$GREEN The profile was loaded in the ram.$RESETCOLOR\n"
		notify "The profile was loaded in the ram."
		sleep 0.4
		killall -q iceweasel firefox
		iceweasel -profile /dev/shm/.mozilla/firefox/profile/a6mpn2rf.default &
		exit
	else
		echo -e "\n[$CYAN nfo$RESETCOLOR ]$GREEN Please wait ...$RESETCOLOR\n"
		notify "Please wait ..."
		sleep 0.3
		cd /opt/anonsectunnel/
		cp $profile /dev/shm/ #> /dev/null
		sleep 0.3
		cd /dev/shm/
		tar xzvf $profile #> /dev/null
		sleep 0.3
		echo -e "\n[$CYAN nfo$RESETCOLOR ]$GREEN The profile was loaded in the ram.$RESETCOLOR\n"
		notify "Starting browser in RAM-only mode"
		sleep 0.4
		killall -q iceweasel firefox
		iceweasel -profile /dev/shm/.mozilla/firefox/profile/a6mpn2rf.default &
		exit
	fi
}






function start {
	# Make sure only root can run this script
	if [ $(id -u) -ne 0 ]; then
		echo -e -e "\n$GREEN[$RED!$GREEN] $RED This script must be run as root$RESETCOLOR\n" >&2
		exit 1
	fi
	
	# Check defaults for Tor
	grep -q -x 'RUN_DAEMON="yes"' /etc/default/tor
	if [ $? -ne 0 ]; then
		echo -e "\n$GREEN[$RED!$GREEN]$RED Please add the following to your /etc/default/tor and restart service:$RESETCOLOR\n" >&2
		echo -e "$GREEN#----------------------------------------------------------------------#$RESETCOLOR"
		echo -e 'RUN_DAEMON="yes"'
		echo -e "$GREEN#----------------------------------------------------------------------#$RESETCOLOR\n"
		exit 1
	fi	
	
	# Check torrc config file
	grep -q -x 'VirtualAddrNetwork 10.192.0.0/10' /etc/tor/torrc
	if [ $? -ne 0 ]; then
		echo -e "\n$RED[!] Please add the following to your /etc/tor/torrc and restart service:$RESETCOLOR\n" >&2
		echo -e "$GREEN#----------------------------------------------------------------------#$RESETCOLOR"
		echo -e 'VirtualAddrNetwork 10.192.0.0/10'
		echo -e 'AutomapHostsOnResolve 1'
		echo -e 'TransPort 9040'
		echo -e 'SocksPort 9050'
		echo -e 'DNSPort 53'
		echo -e 'RunAsDaemon 1'
		echo -e "$GREEN#----------------------------------------------------------------------#$RESETCOLOR\n"
	exit 1
	fi
	grep -q -x 'AutomapHostsOnResolve 1' /etc/tor/torrc
	if [ $? -ne 0 ]; then
		echo -e "\n$RED[!] Please add the following to your /etc/tor/torrc and restart service:$RESETCOLOR\n" >&2
		echo -e "$GREEN#----------------------------------------------------------------------#$RESETCOLOR"
		echo -e 'VirtualAddrNetwork 10.192.0.0/10'
		echo -e 'AutomapHostsOnResolve 1'
		echo -e 'TransPort 9040'
		echo -e 'SocksPort 9050'
		echo -e 'DNSPort 53'
		echo -e 'RunAsDaemon 1'
		echo -e "$GREEN#----------------------------------------------------------------------#$RESETCOLOR\n"
		exit 1
	fi
	grep -q -x 'TransPort 9040' /etc/tor/torrc
	if [ $? -ne 0 ]; then
		echo -e "\n$RED[!] Please add the following to your /etc/tor/torrc and restart service:$RESETCOLOR\n" >&2
		echo -e "$GREEN#----------------------------------------------------------------------#$RESETCOLOR"
		echo -e 'VirtualAddrNetwork 10.192.0.0/10'
		echo -e 'AutomapHostsOnResolve 1'
		echo -e 'TransPort 9040'
		echo -e 'SocksPort 9050'
		echo -e 'DNSPort 53'
		echo -e 'RunAsDaemon 1'
		echo -e "$GREEN#----------------------------------------------------------------------#$RESETCOLOR\n"
	exit 1
	fi
	grep -q -x 'SocksPort 9050' /etc/tor/torrc
	if [ $? -ne 0 ]; then
		echo -e "\n$RED[!] Please add the following to your /etc/tor/torrc and restart service:$RESETCOLOR\n" >&2
		echo -e "$GREEN#----------------------------------------------------------------------#$RESETCOLOR"
		echo -e 'VirtualAddrNetwork 10.192.0.0/10'
		echo -e 'AutomapHostsOnResolve 1'
		echo -e 'TransPort 9040'
		echo -e 'SocksPort 9050'
		echo -e 'DNSPort 53'
		echo -e 'RunAsDaemon 1'
		echo -e "$GREEN#----------------------------------------------------------------------#$RESETCOLOR\n"
	#exit 1
	fi
	grep -q -x 'DNSPort 53' /etc/tor/torrc
	if [ $? -ne 0 ]; then
		echo -e "\n$RED[!] Please add the following to your /etc/tor/torrc and restart service:$RESETCOLOR\n" >&2
		echo -e "$GREEN#----------------------------------------------------------------------#$RESETCOLOR"
		echo -e 'VirtualAddrNetwork 10.192.0.0/10'
		echo -e 'AutomapHostsOnResolve 1'
		echo -e 'TransPort 9040'
		echo -e 'SocksPort 9050'
		echo -e 'DNSPort 53'
		echo -e 'RunAsDaemon 1'
		echo -e "$GREEN#----------------------------------------------------------------------#$RESETCOLOR\n"
		exit 1
	fi
	grep -q -x 'RunAsDaemon 1' /etc/tor/torrc
	if [ $? -ne 0 ]; then
		echo -e "\n$RED[!] Please add the following to your /etc/tor/torrc and restart service:$RESETCOLOR\n" >&2
		echo -e "$GREEN#----------------------------------------------------------------------#$RESETCOLOR"
		echo -e 'VirtualAddrNetwork 10.192.0.0/10'
		echo -e 'AutomapHostsOnResolve 1'
		echo -e 'TransPort 9040'
		echo -e 'SocksPort 9050'
		echo -e 'DNSPort 53'
		echo -e 'RunAsDaemon 1'
		echo -e "$GREEN#----------------------------------------------------------------------#$RESETCOLOR\n"
		#exit 1
	fi
	
	echo -e "\n$RED[$GREEN i$GREEN ]$GREEN Starting AnonSec Tunnel mode:$RESETCOLOR\n"
	
	if [ ! -e /var/run/tor/tor.pid ]; then
		echo -e " $RED*$GREEN Tor is not running! $GREEN starting it $GREEN for you\n" >&2
		echo -e -n " $RED*$GREEN Service " 
		sudo service resolvconf stop
		sudo service dnsmasq stop
		sudo service nscd stop
		sleep 4
		sudo service tor start
		sleep 6
	fi
	if ! [ -f /etc/network/iptables.rules ]; then
		iptables-save > /etc/network/iptables.rules
		echo -e " $RED*$GREEN Saved iptables rules"
	fi
	
	iptables -F
	iptables -t nat -F
	
	sudo cp /etc/resolv.conf /etc/resolv.conf.bak
	sudo touch /etc/resolv.conf
	echo -e 'nameserver 127.0.0.1\nnameserver 213.73.91.35\nnameserver 87.118.100.175' > /etc/resolv.conf
	echo -e " $GREEN*$GREEN Modified resolv.conf to use Tor,ccc.de(Chaos Computer Club)&German Privacy Foundation"

	# set iptables nat
	iptables -t nat -A OUTPUT -m owner --uid-owner $TOR_UID -j RETURN
	iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 53
	iptables -t nat -A OUTPUT -p tcp --dport 53 -j REDIRECT --to-ports 53
	iptables -t nat -A OUTPUT -p udp -m owner --uid-owner $TOR_UID -m udp --dport 53 -j REDIRECT --to-ports 53
	
	#resolve .onion domains mapping 10.192.0.0/10 address space
	iptables -t nat -A OUTPUT -p tcp -d 10.192.0.0/10 -j REDIRECT --to-ports 9040
	iptables -t nat -A OUTPUT -p udp -d 10.192.0.0/10 -j REDIRECT --to-ports 9040
	
	#exclude local addresses
	for NET in $TOR_EXCLUDE 127.0.0.0/9 127.128.0.0/10; do
		iptables -t nat -A OUTPUT -d $NET -j RETURN
	done
	
	#redirect all other output through TOR
	iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports $TOR_PORT
	iptables -t nat -A OUTPUT -p udp -j REDIRECT --to-ports $TOR_PORT
	iptables -t nat -A OUTPUT -p icmp -j REDIRECT --to-ports $TOR_PORT
	
	#accept already established connections
	iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	
	#exclude local addresses
	for NET in $TOR_EXCLUDE 127.0.0.0/8; do
		iptables -A OUTPUT -d $NET -j ACCEPT
	done
	
	#allow only tor output
	iptables -A OUTPUT -m owner --uid-owner $TOR_UID -j ACCEPT
	iptables -A OUTPUT -j REJECT

	echo -e "$GREEN *$GREEN All traffic was redirected through Tor @\n"
	curl icanhazip.com
	echo -e "$GREEN[$GREEN i$GREEN ]$GREEN You are now routed through AnonSec Tunnel$RESETCOLOR\n"
	notify "Global Anonymous Proxy Activated"
	sleep 4
}





function stop {
	# Make sure only root can run our script
	if [ $(id -u) -ne 0 ]; then
		echo -e "\n$GREEN[$RED!$GREEN] $RED This script must be run as root$RESETCOLOR\n" >&2
		exit 1
	fi
	echo -e "\n$GREEN[$GREEN i$GREEN ]$GREEN Stopping AnonSecTunnel:$RESETCOLOR\n"

	iptables -F
	iptables -t nat -F
	echo -e " $GREEN*$GREEN Deleted all iptables rules"
	
	if [ -f /etc/network/iptables.rules ]; then
		iptables-restore < /etc/network/iptables.rules
		sudo rm /etc/network/iptables.rules
		echo -e " $GREEN*$GREEN Iptables rules restored"
	fi
	echo -e -n " $GREEN*$GREEN Service "
	if [ -e /etc/resolv.conf.bak ]; then
		sudo rm /etc/resolv.conf
		sudo cp /etc/resolv.conf.bak /etc/resolv.conf
	fi
	service tor stop
	sleep 4
	service resolvconf start
	service nscd start
	service dnsmasq start
	sleep 1
	
	echo -e " $GREEN*$GREEN AnoonSec Tunnel stopped\n"
	notify "Global Anonymous Proxy Stopped"
	sleep 4
}

function change {
	ipcheck=$(wget -qO- www.icanhazip.com)
	service tor reload
	sleep 4
	echo -e " $GREEN*$GREEN Tor IP & ExitNode Changed!\n"
	notify "New TOR IP:\n$ipcheck"
	#curl www.icanhazip.com
	sleep 1
}

function status {
	service tor status
}

case "$1" in
	start)
		init
		start
	;;
	stop)
		init
		stop
	;;
	change)
		change
	;;
	status)
		status
	;;
	myip)
		ip
	;;
	iceweasel_tor)
		iceweasel_tor
	;;
	starti2p)
		starti2p
	;;
	stopi2p)
		stopi2p
	;;
	restart)
		$0 stop
		sleep 1
		$0 start
	;;
   *)
echo -e "
AnonSecTunnel Module (v 1.3.1)
	Usage:
	$RED┌──[$GREEN$USER$YELLOW@$GREEN`hostname`$RED]─[$GREEN$PWD$RED]
	$RED└──╼ \$$GREEN"" AnonSec Tunnel $RED{$GREEN""start$RED|$GREEN""stop$RED|$GREEN""restart$RED|$GREEN""change$RED""$RED|$GREEN""status$RED""}
	
	$RED start$GREEN -$GREEN Start system-wide anonymous
		  tunneling under TOR proxy through iptables	  
	$RED stop$GREEN -$GREEN Reset original iptables settings
		  and return to clear navigation
	$RED restart$GREEN -$GREEN Combines \"stop\" and \"start\" options
	$RED change$GREEN -$GREEN Changes identity restarting TOR
	$RED status$GREEN -$GREEN Check if AnonSec Tunnel is working properly
	----[ I2P related features ]----
	$RED starti2p$GREEN -$GREEN Start i2p services
	$RED stopi2p$GREEN -$GREEN Stop i2p services
	
$RESETCOLOR" >&2

exit 1
;;
esac

echo -e $RESETCOLOR
exit 0
