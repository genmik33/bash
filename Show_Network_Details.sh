#!/bin/bash
RED='\e[31m'
BLUE='\033[36m'
GREEN='\033[32m'
RESET='\033[0m'
BOLD="\e[1m"
clear
User=$(whoami)
if [[ $User != "root" ]]; then
    echo ""
    echo -e "${BOLD}${RED}      ¡¡¡ Run as root !!! ${RESET}"  
    echo ""
    echo -e "Try: ${BOLD}${GREEN}sudo ./namefile.sh ${RESET}${BLUE}<Net_Card>${RESET}"
    echo ""
else
    net_info(){     
        echo -e "${BLUE}Card's Name: ${RESET}${BOLD}${GREEN}$1${RESET}"
        echo -e "${BLUE}MAC Address: ${RESET}"${BOLD}${GREEN}$(ifconfig $1 | grep "ether" | tr -s ' ' | cut -d ' ' -f 3)${RESET}
        if [[ $(ifconfig $1 | grep "ether" | tr -s ' ' | cut -d ' ' -f 3) == $(ifconfig $1 | awk 'NR==2' | tr -s ' ' | cut -d ' ' -f 3) ]]; then
            echo -e "${BLUE}IPv4 Address: ${RESET}${RED}Unknown${RESET}"
            echo -e "${BLUE}IPv4 Address Mask: ${RESET}${RED}Unknown${RESET}"
            echo -e "${BLUE}IPv4 Address Gateway: ${RESET}${RED}Unknown${RESET}"
            echo -e "${BLUE}IPv4 Address Broadcast: ${RESET}${RED}Unknown${RESET}"
            echo -e "${BLUE}IPv4 Address DHCP Server: ${RESET}${RED}Unknown${RESET}"
            echo -e "${BLUE}IPv4 Address DNS Server: ${RESET}${RED}Unknown${RESET}"
        else
            echo -e "${BLUE}IPv4 Address: ${RESET}"${GREEN}$(ifconfig $1 | awk 'NR==2' | tr -s ' ' | cut -d ' ' -f 3)${RESET}
            IPv4=$(ifconfig $1 | awk 'NR==2' | tr -s ' ' | cut -d ' ' -f 3)
            echo -e "${BLUE}IPv4 Address Mask: ${RESET}"${GREEN}$(ifconfig $1 | awk 'NR==2' | tr -s ' ' | cut -d ' ' -f 5)${RESET}
            echo -e "${BLUE}IPv4 Address Gateway: ${RESET}"${GREEN}$(netstat -n -r | grep "$1" | grep ^"0.0.0.0" | tr -s ' ' | cut -d ' ' -f 2)${RESET}
            echo -e "${BLUE}IPv4 Address Broadcast: ${RESET}"${GREEN}$(ifconfig $1 | awk 'NR==2' | tr -s ' ' | cut -d ' ' -f 7)${RESET}
            if [[ $(sudo cat /var/log/syslog | grep dhclient | grep DHCPACK | grep "$IPv4" | cut -d ' ' -f 10 | tail -n 1 | tr '.' ' ' | wc -w) == 4 ]]; then
                echo -e "${BLUE}IPv4 Address DHCP Server: ${RESET}"${GREEN}$(sudo cat /var/log/syslog | grep dhclient | grep DHCPACK | grep "$IPv4" | cut -d ' ' -f 10 | tail -n 1)${RESET}
            else
                echo -e "${BLUE}IPv4 Address DHCP Server: ${RESET}${RED}Unknown${RESET}"
            fi
            Num_Dns=$(nmcli device show $1 | grep "IP4.DNS" | tr -s ' ' | cut -d ' ' -f 2 | wc -l)
            comp=$Num_Dns
            if [[ $Num_Dns -gt 1 ]]; then
                while [ $Num_Dns -gt 0 ]; do
                    if [[ $comp -eq $Num_Dns ]]; then
                        Ip_dns="$(nmcli device show $1 | grep "IP4.DNS" | tr -s ' ' | cut -d ' ' -f 2 | awk 'NR=='$Num_Dns''), "
                    elif [[ $Num_Dns -eq 1 ]]; then
                        Ip_dns="$Ip_dns$(nmcli device show $1 | grep "IP4.DNS" | tr -s ' ' | cut -d ' ' -f 2 | awk 'NR=='$Num_Dns'')"
                    else
                        Ip_dns="$Ip_dns$(nmcli device show $1 | grep "IP4.DNS" | tr -s ' ' | cut -d ' ' -f 2 | awk 'NR=='$Num_Dns''), "
                    fi
                    Num_Dns=$(($Num_Dns - 1))
                done
                echo -e "${BLUE}IPv4 Address DNS Server: ${RESET}${GREEN}$Ip_dns"${RESET}
            else
                echo -e "${BLUE}IPv4 Address DNS Server: ${RESET}"${GREEN}$(nmcli device show $1 | grep "IP4.DNS" | tr -s ' ' | cut -d ' ' -f 2 | awk 'NR=='$Num_Dns'')${RESET}
            fi
        fi
        echo ""
    }
    echo ""
    if [[ -z "$1" ]]; then
        Num_Net=$(ip a | grep "state UP" | cut -d ' ' -f 2 | cut -d ':' -f 1 | wc -l)
        if [[ $Num_Net -eq 0 ]]; then
            echo -e "${RED}Network card(s) not found or not connected.${RESET}"
            echo ""
        elif [[ $Num_Net -eq 1 ]]; then
            echo "Information about your network:"
            echo ""
            Card_Name=$(ip a | grep "state UP" | cut -d ' ' -f 2 | cut -d ':' -f 1)
            net_info $Card_Name
            echo ""
        else
            echo "Information about your networks:"
            echo ""
            while [ $Num_Net -gt 0 ]; do
                Card_Name=$(ip a | grep "state UP" | cut -d ' ' -f 2 | cut -d ':' -f 1 | awk 'NR=='$Num_Net'')
                net_info $Card_Name
                Num_Net=$(($Num_Net - 1))
                echo ""
            done
        fi
    else
        ifconfig $1 &> /dev/null
        if [[ $? -eq 1 ]]; then
            echo -e "${RED}Network Card Not Found${RESET}"
            echo ""
        else
            echo "Information about your network:"
            echo ""
            net_info $1
        fi
    fi
fi