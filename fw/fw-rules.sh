#!/bin/sh

if [ $# -ne 1 ]
	then
	 echo "Necesito un parametro [start | stop]"
	exit 1
fi

case $1 in
"start")
DMZ_NET="172.20.109.0/24"
LAN_NET="192.168.109.0/24"

DMZ_IF="ens3"
WAN_IF="ens8"
LAN_IF="ens9"

DMZ_IP="172.20.109.254"
WAN_IP="10.3.4.138"
LAN_IP="192.168.109.254"

# default policies

	iptables -P INPUT DROP
	iptables -P OUTPUT DROP
	iptables -P FORWARD DROP

	# SSH LAN access rules

	iptables -A INPUT -i $LAN_IF -d $LAN_IP -p TCP --dport 2222 -j ACCEPT
	iptables -A OUTPUT -o $LAN_IF -s $LAN_IP -p TCP --sport 2222 -j ACCEPT

	# SSH WAN access rules

	iptables -A INPUT -i $WAN_IF -d $WAN_IP -p TCP --dport 2222 -j ACCEPT
	iptables -A OUTPUT -o $WAN_IF -s $WAN_IP -p TCP --sport 2222 -j ACCEPT

	# SSH  DMZ access rules

	iptables -A INPUT -i $DMZ_IF -d $DMZ_IP -p TCP --dport 2222 -j ACCEPT
	iptables -A OUTPUT -o $DMZ_IF -s $DMZ_IP -p TCP --sport 2222 -j ACCEPT

	# DHCP access rules DMZ

	iptables -A OUTPUT -o $WAN_IF -p udp --dport 67 --sport 68 -j ACCEPT
	iptables -A INPUT -i $WAN_IF -p udp --sport 67 --dport 68 -j ACCEPT


	#REGLA 8
	iptables -A FORWARD -s $LAN_NET -d $DMZ_NET -p tcp --dport 22 -j ACCEPT
	#REGLA 9
	iptables -A FORWARD -s $LAN_NET -d $DMZ_NET -p udp --dport 53 -j ACCEPT
	#REGLA 10
	iptables -A FORWARD -s $LAN_NET -d $DMZ_NET -p tcp --dport 80 -j ACCEPT
	#REGLA 11
	iptables -A FORWARD -s $LAN_NET -d $DMZ_NET -p tcp --dport 443 -j ACCEPT
	#REGLA 12
	iptables -A FORWARD -p icmp -j ACCEPT
	iptables -A INPUT -p icmp -j ACCEPT
	iptables -A OUTPUT -p icmp -j ACCEPT
	#REGLAS 13
	iptables -A FORWARD -s $LAN_NET -d $DMZ_NET -p tcp --dport 80 -i ens8 -j ACCEPT
	#REGLAS 14
	iptables -A FORWARD -s $LAN_NET -d $DMZ_NET -p tcp --dport 443 -i ens8 -j ACCEPT
	#REGLA POSTFORWARDING
	iptables -t nat -A PREROUTING -i ens8 -p tcp --dport 80 -j DNAT --to 172.20.111.22

	iptables -t nat -A PREROUTING -i ens8 -d 10.3.4.193 -p tcp --dport 22 -j DNAT --to 172.20.111.22
	iptables -A FORWARD -i ens8 -o ens3 -p tcp --dport 22 -d 172.20.111.22 -j ACCEPT
	iptables -A FORWARD -i ens3 -o ens8 -p tcp --sport 22 -s 172.20.111.22 -j ACCEPT

	#PREGUNTA Y RESPUESTA DEL SSH EXTERIOR-WAN
	iptables -A INPUT -i $WAN_IF -d $WAN_IP -p tcp --dport 2222 -j ACCEPT
	iptables -A OUTPUT -o $WAN_IF -m state --state ESTABLISHED,RELATED -p tcp --sport 2222 -j ACCEPT

	#PREGUNTA Y RESPUESTA DEL SSH WAN-LAN
	iptables -A INPUT -i $LAN_IF -d $LAN_IP -p tcp --dport 2222 -j ACCEPT
	iptables -A OUTPUT -o $LAN_IF -m state --state ESTABLISHED,RELATED -p tcp --sport 2222 -j ACCEPT

	#PREGUNTA Y RESPUESTA DEL SSH LAN-DMZ
	iptables -A INPUT -i $DMZ_IF -d $DMZ_IP -p tcp --dport 2222 -j ACCEPT
	iptables -A OUTPUT -o $DMZ_IF -m state --state ESTABLISHED,RELATED -p tcp --sport 2222 -j ACCEPT



	;;
"stop")
	iptables -F
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD ACCEPT
	;;

*)
	echo "Se necesita un parametro valido [start | stop]"
	exit 2
	;;
esac
exit 0

