#!/bin/bash

# This script uses iptables to control badnwith for different ports


############################
# alle evtl. bestehenden tc regeln loeschen
############################
tc qdisc del dev eth0 root

##############################
# iptables mangle auf null setzen
##############################
iptables -t mangle -F

#######################################
# htb der schnittstelle eth0 zuordnen bzw aktivieren
# Hier wird für dem Interface eth0 ein root handle (Bezeichner) mit der Ziffer 1:0 (oft auch nur als 1: geschrieben) zugeordnet
# qdisc = queuing discipline
######################################
tc qdisc add dev eth0 root handle 1:0 htb default 10

###############################
# Nun müssen dem root - Handle Traffic-Klassen zugeordnet werden, 
# beginnend mit der parent - Klasse 1:0, die die Wurzel des Baumes 
# der weiteren Traffic - Klassen darstellt:
#
# rate legt fest, wie die Bandbreite im Verhältnis aufgeteilt werden soll (90% zu 10%),
# wenn Vollast anliegt (100mbit). ceil definiert ein oberes, maximales Limit, welches genutzt werden darf,
# wenn kein anderer Traffic vorhanden ist.
###############################
tc class add dev eth0 parent 1:0 classid 1:1 htb rate 100mbit ceil 100mbit 
tc class add dev eth0 parent 1:1 classid 1:10 htb rate 80mbit ceil 100mbit 
tc class add dev eth0 parent 1:1 classid 1:11 htb rate 100mbit ceil 5mbit # ftp gruppe
tc class add dev eth0 parent 1:1 classid 1:12 htb rate 100mbit ceil 1mbit  

###############################
# Die "Marker" (10,11,12) ist die Verbindung zum Linux Paketfilter
# der aus dem Datenstrom Pakete identifiziert und für QoS - Klassen markiert.
# Dies geschieht entweder durch das iptables - Kommando, oder mit ip:
###############################
iptables -A POSTROUTING -t mangle -o eth0 -p tcp --sport 21 -j MARK --set-mark 11
iptables -A POSTROUTING -t mangle -o eth0 -p tcp --sport 20 -j MARK --set-mark 11
###############################
# Die eigentliche Zuordnung der markierten Paketen
# zu den Klassen erfolgt erst mit noch einem weiteren Kommando:
###############################
tc filter add dev eth0 parent 1: prio 0 protocol ip handle 11 fw flowid 1:11




exit 0
