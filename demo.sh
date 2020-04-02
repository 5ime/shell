#!/bin/sh

MAINIP=$(ip route get 1 | awk '{print $NF;exit}')
GATEWAYIP=$(ip route | grep default | awk '{print $3}')
SUBNET=$(ip -o -f inet addr show | awk '/scope global/{sub(/[^.]+\//,"0/",$4);print $4}' | head -1 | awk -F '/' '{print $2}')

value=$(( 0xffffffff ^ ((1 << (32 - $SUBNET)) - 1) ))
NETMASK="$(( (value >> 24) & 0xff )).$(( (value >> 16) & 0xff )).$(( (value >> 8) & 0xff )).$(( value & 0xff ))"

sh_ver="2.0.1"


clear
echo "                                                           "
echo "###########################################################"
echo "#                                                         #"
echo "#                      懒人专用                           #"
echo "#  博客：https://5ime.cn                                  #"
echo "#  脚本来源于网络，版权归各位所有                         #"
echo "#                                                         #"
echo "###########################################################"
echo "                                                           "
echo "请选择您需要的程序:"
echo "  1) Caddy一键安装脚本"
echo "  2) SSR一键脚本"
echo "  3) SSR一键脚本Plus"
echo "  4) V2ary一键安装脚本"
echo "  5) BBR四合一安装脚本"
echo "  6) Aria2+自动上传OneDrive"
echo "  7) Telegram代理（Go版）"
echo "  8) 傻瓜式一键DD包（OD源）"
echo "  9) 傻瓜式一键DD包（GD源）"
echo ""
echo -n "请输入编号: "
read N
case $N in
  1) wget -N --no-check-certificate https://raw.githubusercontent.com/5ime/shell/master/caddy_install.sh && chmod +x caddy_install.sh && bash caddy_install.sh ;;
  2) wget -N --no-check-certificate https://raw.githubusercontent.com/5ime/shell/master/ssr.sh && chmod +x ssr.sh && bash ssr.sh ;;
  3) wget -N --no-check-certificate https://raw.githubusercontent.com/5ime/shell/master/ssrmu.sh && chmod +x ssrmu.sh && bash ssrmu.sh ;;
  4) wget -N --no-check-certificate https://raw.githubusercontent.com/5ime/shell/master/v2ray.sh && chmod +x v2ray.sh && bash v2ray.sh ;;
  5) wget -N --no-check-certificate https://raw.githubusercontent.com/5ime/shell/master/tcp.sh && chmod +x tcp.sh && ./tcp.sh ;;
  6) wget -N --no-check-certificate https://raw.githubusercontent.com/5ime/shell/master/install_auto_aria2.sh && chmod +x install_auto_aria2.sh && ./install_auto_aria2.sh ;;
  7) wget -N --no-check-certificate https://raw.githubusercontent.com/5ime/shell/master/mtproxy_go.sh && chmod +x mtproxy_go.sh && bash mtproxy_go.sh ;;
  8) wget -N --no-check-certificate https://raw.githubusercontent.com/veip007/dd/master/dd-od.sh && chmod +x dd-od.sh  && ./dd-od.sh ;;
  9) wget -N --no-check-certificate https://raw.githubusercontent.com/veip007/dd/master/dd-gd.sh && chmod +x dd-gd.sh  && ./dd-gd.sh ;;
  *) echo "Wrong input!" ;;
esac
