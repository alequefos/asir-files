
#!/bin/sh
if [ $# -ne 1 ]
	then
		echo "NECESITO un PARAMETRO start o stop"
exit 0
fi 
	case $1 in
	"start")

#REGLAS BASICAS
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

#ACCESO DE LA REGLAS DE LA WAN

iptables -A INPUT -i ens4 -d 10.3.4.193 -p tcp --dport 2222 -j ACCEPT
iptables -A OUTPUT -o ens4 -s 10.3.4.193 -p tcp --sport 2222 -j ACCEPT

#ACCESO A LAS REGLAS DE LA LAN

iptables -A INPUT -i ens10 -d 192.168.111.254 -p tcp --dport 2222 -j ACCEPT
iptables -A OUTPUT -o ens10 -s 192.168.111.0/24 -p tcp --sport 2222 -j ACCEPT

#ACCESO A LAS REGLAS DE LA DMZ

iptables -A INPUT -i ens3 -d 172.20.111.254 -p tcp --dport 2222 -j ACCEPT
iptables -A OUTPUT -o ens3 -s 172.20.111.0/24 -p tcp --sport 2222 -j ACCEPT

#ACCESo A LAS REGLAS DEL DHCP
iptables -A OUTPUT -o ens8 -p udp --dport 67 --sport 68 -j ACCEPT
iptables -A INPUT -i ens8 -p udp --sport 67 --dport 68 -j ACCEPT

#REGLA 8
iptables -A FORWARD -s 192.168.111.0/24 -d 172.20.111.0/24 -p tcp --dport 22 -j ACCEPT
#REGLA 9
iptables -A FORWARD -s 192.168.111.0/24 -d 172.20.111.0/24 -p udp --dport 53 -j ACCEPT
#REGLA 10
iptables -A FORWARD -s 192.168.111.0/24 -d 172.20.111.0/24 -p tcp --dport 80 -j ACCEPT
#REGLA 11
iptables -A FORWARD -s 192.168.111.0/24 -d 172.20.111.0/24 -p tcp --dport 443 -j ACCEPT
#REGLA 12
iptables -A FORWARD -p icmp -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT
#REGLAS 13
iptables -A FORWARD -s 192.168.111.0/24 -d 172.20.111.0/24 -p tcp --dport 80 -i ens8 -j ACCEPT
#REGLAS 14
iptables -A FORWARD -s 192.168.111.0/24 -d 172.20.111.0/24 -p tcp --dport 443 -i ens8 -j ACCEPT
#REGLA POSTFORWARDING
iptables -t nat -A PREROUTING -i ens8 -p tcp --dport 80 -j DNAT --to 172.20.111.22

iptables -t nat -A PREROUTING -i ens8 -d 10.3.4.193 -p tcp --dport 22 -j DNAT --to 172.20.111.22
iptables -A FORWARD -i ens8 -o ens3 -p tcp --dport 22 -d 172.20.111.22 -j ACCEPT
iptables -A FORWARD -i ens3 -o ens8 -p tcp --sport 22 -s 172.20.111.22 -j ACCEPT


;;

"stop")
iptables -F
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
;;
*)
echo "SE NECESITA UN PARAMETRPO start o stop"
	exit
;;
esac
exit 0
