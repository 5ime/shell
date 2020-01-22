#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#config
filepath=$(cd "$(dirname "$0")"; pwd)
file_1=$(echo -e "${filepath}"|awk -F "$0" '{print $1}')
file="/root/.aria2"
aria2_conf="/root/.aria2/aria2.conf"
aria2_log="/root/.aria2/aria2.log"
Folder="/usr/local/aria2"
aria2c="/usr/bin/aria2c"
Crontab_file="/usr/bin/crontab"
auto_upload="/usr/local/etc/OneDrive"

#fonts color
Green_font="\033[32m" 
Red_font="\033[31m" 
Green_background="\033[42;37m" 
Red_background="\033[41;37m"  
Font="\033[0m"

Info="${Green_font}[信息]${Font}"
Error="${Red_font}[错误]${Font}"
Tip="${Green_font}[注意]${Font}"

#检查ROOT权限
check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} 当前非ROOT账号，请切换ROOT在执行当前脚本${Font}" && exit 1
}

#检查系统
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	bit=`uname -m`
}

#安装依赖环境
Installation_dependency(){
	if [[ ${release} = "centos" ]]; then
		yum update
		yum -y groupinstall "Development Tools"
		yum install nano -y
		yum install curl -y
	else
		apt-get update
		apt-get install nano build-essential curl -y
	fi
}

#获得版本号
get_newVer(){
     aria2_new_ver=$(wget --no-check-certificate -qO- https://api.github.com/repos/q3aql/aria2-static-builds/releases | grep -o '"tag_name": ".*"' |head -n 1| sed 's/"//g;s/v//g' | sed 's/tag_name: //g')
	 if [[ -z ${aria2_new_ver} ]]; then
			echo -e "${Error} Aria2 最新版本获取失败，请手动获取最新版本号[ https://github.com/q3aql/aria2-static-builds/releases ]"
			read -e -p "请输入版本号 [ 格式如 1.34.0 ] :" aria2_new_ver
			[[ -z "${aria2_new_ver}" ]] && echo "取消..." && exit 1
		else
			echo -e "${Info} 检测到 Aria2 最新版本为 [ ${aria2_new_ver} ]"
		fi
}

#下载aria2
download_aria2(){
	 cd "/usr/local"
	 if [[ ${bit} == "x86_64" ]]; then
		bit="64bit"
	 elif [[ ${bit} == "i386" || ${bit} == "i686" ]]; then
		bit="32bit"
	 else
		bit="arm-rbpi"
	 fi
	 wget -N --no-check-certificate "https://github.com/q3aql/aria2-static-builds/releases/download/v${aria2_new_ver}/aria2-${aria2_new_ver}-linux-gnu-${bit}-build1.tar.bz2"
	 Aria2_Name="aria2-${aria2_new_ver}-linux-gnu-${bit}-build1"
	 [[ ! -s "${Aria2_Name}.tar.bz2" ]] && echo -e "${Error} aria2 压缩包下载失败 !" && exit 1
	 tar jxvf "${Aria2_Name}.tar.bz2"
	 [[ ! -e "/usr/local/${Aria2_Name}" ]] && echo -e "${Error} Aria2 解压失败 !" && rm -rf "${Aria2_Name}.tar.bz2" && exit 1
	 mv "/usr/local/${Aria2_Name}" "${Folder}"
	 [[ ! -e "${Folder}" ]] && echo -e "${Error} aria2 文件夹重命名失败 !" && rm -rf "${Aria2_Name}.tar.bz2" && rm -rf "/usr/local/${Aria2_Name}" && exit 1
	 rm -rf "${Aria2_Name}.tar.bz2"
	 cd "${Folder}"
	 make install
	 [[ ! -e ${aria2c} ]] && echo -e "${Error} aria2 主程序安装失败！" && rm -rf "${Folder}" && exit 1
	 chmod +x aria2c
}

#下载aria2 配置文件
download_aria2_conf(){
     mkdir "${file}" && cd "${file}"
	 wget --no-check-certificate -N "https://67zz.cn/shell/aria2.conf"
	 [[ ! -s "aria2.conf" ]] && echo -e "${Error} Aria2 配置文件下载失败 !" && rm -rf "${file}" && exit 1
	 wget --no-check-certificate -N "https://67zz.cn/Aria2/dht.dat"
	 [[ ! -s "dht.dat" ]] && echo -e "${Error} Aria2 DHT文件下载失败 !" && rm -rf "${file}" && exit 1
	 echo '' > aria2.session
	 stty erase '^H' && read -p "请输入aria2密钥:" pass
	 sed -i 's/^rpc-secret=67zz.cn/rpc-secret='${pass}'/g' ${aria2_conf}
	 
}

#下载服务脚本
service_aria2(){
     if [[ ${release} = "centos" ]]; then
		if ! wget --no-check-certificate https://67zz.cn/shell/aria2_centos -O /etc/init.d/aria2; then
			echo -e "${Error} aria2服务 管理脚本下载失败 !" && exit 1
		fi
		chmod +x /etc/init.d/aria2
		chkconfig --add aria2
		chkconfig aria2 on
	 else
		if ! wget --no-check-certificate https://67zz.cn/shell/aria2_debian -O /etc/init.d/aria2; then
			echo -e "${Error} aria2服务 管理脚本下载失败 !" && exit 1
		fi
		chmod +x /etc/init.d/aria2
		update-rc.d -f aria2 defaults
	 fi
	 echo -e "${Info} Aria2服务 管理脚本下载完成 !"
}
read_config(){
	status_type=$1
	if [[ ! -e ${aria2_conf} ]]; then
		if [[ ${status_type} != "un" ]]; then
			echo -e "${Error} Aria2 配置文件不存在 !" && exit 1
		fi
	else
		conf_text=$(cat ${aria2_conf}|grep -v '#')
		aria2_dir=$(echo -e "${conf_text}"|grep "dir="|awk -F "=" '{print $NF}')
		aria2_port=$(echo -e "${conf_text}"|grep "rpc-listen-port="|awk -F "=" '{print $NF}')
		aria2_passwd=$(echo -e "${conf_text}"|grep "rpc-secret="|awk -F "=" '{print $NF}')
	fi
	
}

#配置防火墙
add_iptables(){
	iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${aria2_RPC_port} -j ACCEPT
	iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${aria2_RPC_port} -j ACCEPT
}
del_iptables(){
	iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport ${aria2_port} -j ACCEPT
	iptables -D INPUT -m state --state NEW -m udp -p udp --dport ${aria2_port} -j ACCEPT
}
save_iptables(){
	if [[ ${release} == "centos" ]]; then
		service iptables save
	else
		iptables-save > /etc/iptables.up.rules
	fi
}
set_iptables(){
	if [[ ${release} == "centos" ]]; then
		service iptables save
		chkconfig --level 2345 iptables on
	else
		iptables-save > /etc/iptables.up.rules
		echo -e '#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules' >/etc/network/if-pre-up.d/iptables
		chmod +x /etc/network/if-pre-up.d/iptables
	fi
}


#更新 bt_tracker 服务器
update_bt_tracker(){
	check_installed_status
	check_pid
	[[ ! -z ${PID} ]] && /etc/init.d/aria2 stop
	bt_tracker_list=$(wget -qO- https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt |awk NF|sed ":a;N;s/\n/,/g;ta")
	if [ -z "`grep "bt-tracker" ${aria2_conf}`" ]; then
		sed -i '$a bt-tracker='${bt_tracker_list} "${aria2_conf}"
		echo -e "${Info} 添加成功..."
	else
		sed -i "s@bt-tracker.*@bt-tracker=$bt_tracker_list@g" "${aria2_conf}"
		echo -e "${Info} 更新成功..."
	fi
	/etc/init.d/aria2 start
}

#安装aria2
aria2_install(){
     check_root
	 [[ -e ${aria2c} ]] && echo -e "${Error}当前系统已经安装aria2了${Font}" && exit 1
	 check_sys
	 echo -e "${Info} 安装依赖..."
	 Installation_dependency
	 echo -e "${Info} 安装主程序..."
	 get_newVer
	 download_aria2
	 echo -e "${Info} 下载配置文件..."
	 download_aria2_conf
	 echo -e "${Info} 安装服务脚本..."
	 service_aria2
	 read_config
	 aria2_RPC_port=${aria2_port}
	 echo -e "${Info} 配置防火墙..."
	 set_iptables
	 add_iptables
	 save_iptables
	 echo -e "${Info} 设置自动更新 BT-Tracker服务器..."
	 set_bt_tracker
}

#卸载aria2
uninstall_aria2(){
     check_installed_status "un"
	 echo " 确定要卸载 aria2? (y/N)"
	 echo
	 read -e -p "(默认: n):" unyn
	 [[ -z ${unyn} ]] && unyn="n"
	 if [[ ${unyn} == [Yy] ]]; then
		check_pid
		[[ ! -z $PID ]] && kill -9 ${PID}
		read_config "un"
		del_iptables
		save_iptables
		cd "${Folder}"
		make uninstall
		cd ..
		rm -rf "${aria2c}"
		rm -rf "${Folder}"
		rm -rf "${file}"
		if [[ ${release} = "centos" ]]; then
			chkconfig --del aria2
		else
			update-rc.d -f aria2 remove
		fi
		rm -rf "/etc/init.d/aria2"
		echo && echo "aria2 卸载完成 !" && echo
	 else
		echo && echo "卸载已取消..." && echo
	 fi
}

#去除防火墙端口
del_iptables(){
	iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport ${aria2_port} -j ACCEPT
	iptables -D INPUT -m state --state NEW -m udp -p udp --dport ${aria2_port} -j ACCEPT
}

#检测是否安装
check_installed_status(){
     [[ ! -e ${aria2c} ]] && echo -e "${Error} aria2 没有安装，请检查 !" && exit 1
	 [[ ! -e ${aria2_conf} ]] && echo -e "${Error} aria2 配置文件不存在，请检查 !" && [[ $1 != "un" ]] && exit 1
}

#检测crontab
check_crontab_installed_status(){
	if [[ ! -e ${Crontab_file} ]]; then
		echo -e "${Error} Crontab 没有安装，开始安装..."
		if [[ ${release} == "centos" ]]; then
			yum install crond -y
		else
			apt-get install cron -y
		fi
		if [[ ! -e ${Crontab_file} ]]; then
			echo -e "${Error} Crontab 安装失败，请检查！" && exit 1
		else
			echo -e "${Info} Crontab 安装成功！"
		fi
	fi
}

#检测PID
check_pid(){
	PID=`ps -ef| grep "aria2c"| grep -v grep| grep -v "aria2.sh"| grep -v "init.d"| grep -v "service"| awk '{print $2}'`
}

#设置自动更新bt-tracker
set_bt_tracker(){
     check_crontab_installed_status
	 crontab_update_start
}

crontab_update_start(){
	crontab -l > "$file_1/crontab.bak"
	sed -i "/aria2.sh update-bt-tracker/d" "$file_1/crontab.bak"
	echo -e "\n0 3 * * 1 /bin/bash $file_1/aria2.sh update-bt-tracker" >> "$file_1/crontab.bak"
	crontab "$file_1/crontab.bak"
	rm -f "$file_1/crontab.bak"
	cron_config=$(crontab -l | grep "aria2.sh update-bt-tracker")
	if [[ -z ${cron_config} ]]; then
		echo -e "${Error} Aria2 自动更新 BT-Tracker服务器 开启失败 !" 
		start_aria2
	else
		echo -e "${Info} Aria2 自动更新 BT-Tracker服务器 开启成功 !"
		Update_bt_tracker_cron
	fi
}

Update_bt_tracker_cron(){
	check_installed_status
	check_pid
	[[ ! -z ${PID} ]] && /etc/init.d/aria2 stop
	bt_tracker_list=$(wget -qO- https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt |awk NF|sed ":a;N;s/\n/,/g;ta")
	if [ -z "`grep "bt-tracker" ${aria2_conf}`" ]; then
		sed -i '$a bt-tracker='${bt_tracker_list} "${aria2_conf}"
		echo -e "${Info} 添加成功..."
	else
		sed -i "s@bt-tracker.*@bt-tracker=$bt_tracker_list@g" "${aria2_conf}"
		echo -e "${Info} 更新成功..."
	fi
	/etc/init.d/aria2 start
}

#启动
start_aria2(){
	check_installed_status
	check_pid
	[[ ! -z ${PID} ]] && echo -e "${Error} Aria2 正在运行，请检查 !" && exit 1
	/etc/init.d/aria2 start
}

#停止
stop_aria2(){
	check_installed_status
	check_pid
	[[ -z ${PID} ]] && echo -e "${Error} Aria2 没有运行，请检查 !" && exit 1
	/etc/init.d/aria2 stop
}

#重启
restart_aria2(){
	check_installed_status
	check_pid
	[[ ! -z ${PID} ]] && /etc/init.d/aria2 stop
	/etc/init.d/aria2 start
}

#安装上传脚本
install_autoUpload(){
     [[ -e ${auto_upload} ]] && echo -e "${Error} 自动上传脚本已经安装，告辞!" && exit 1
	 echo -e "${Info}下载安装自动上传脚本..."
	 mkdir -p ${auto_upload}
     cd ${auto_upload}
	 wget --no-check-certificate -q -O json-parser "https://raw.githubusercontent.com/0oVicero0/OneDrive/master/Business/json-parser"
	 wget --no-check-certificate -q -O onedrive "https://raw.githubusercontent.com/0oVicero0/OneDrive/master/Business/onedrive"
	 wget --no-check-certificate -q -O onedrive-d "https://raw.githubusercontent.com/0oVicero0/OneDrive/master/Business/onedrive-d"
	 wget --no-check-certificate -q -O onedrive-authorize "https://67zz.cn/shell/onedrive-authorize"
	 wget --no-check-certificate -q -O onedrive-base "https://raw.githubusercontent.com/0oVicero0/OneDrive/master/Business/onedrive-base"
	 wget --no-check-certificate -q -O onedrive.cfg "https://67zz.cn/shell/onedrive.cfg"
	 chmod -R a+x ${auto_upload}
	 ln -sf ${auto_upload}/onedrive /usr/local/bin/
	 ln -sf ${auto_upload}/onedrive-d /usr/local/bin/
     rm -rf $(basename "$0")
	 wget -P ${file}  --no-check-certificate -N "https://67zz.cn/shell/autoUpload.sh"
	 sed -i '$a on-download-complete=/root/.aria2/autoUpload.sh' "${aria2_conf}"
	 chmod 777 ${file}/*
	 restart_aria2
	 echo -e "${Green_font}安装完成，复制链接浏览器打开准备授权!"
	 onedrive -a #去授权
}

#卸载上传脚本
uninstall_autoUpload(){
     [[ ! -e ${auto_upload} ]] && echo -e "${Error} 自动上传脚本未安装!" && exit 1
	 rm -rf ${auto_upload}
	 rm ${file}/autoUpload.sh
	 restart_aria2
	 echo -e "${Info} 上传脚本卸载完成"
}

#重新认证
goto_auth(){
     [[ ! -e ${auto_upload} ]] && echo -e "${Error} 自动上传脚本未安装,认证个鸡毛啊!" && exit 1
     onedrive -a #去认证
}

action=$1
if [[ "${action}" == "update-bt-tracker" ]]; then
	Update_bt_tracker_cron
else echo && echo -e "
# ====================================================
#   ${Green_font} aria2+自动上传OneDrive 一键脚本${Font}
#   ${Green_font} 站在巨人肩膀上（chaoxi）二次开发 ${Font}
#   ${Green_font} 作者：Eleven ${Font}
#   ${Green_font} 网站：https://67zz.cn ${Font}
# ====================================================

 ${Green_font} 1.${Font} 安装 aria2
 ${Green_font} 2.${Font} 卸载 aria2
 ${Green_font} 3.${Font} 重启 aria2
 ${Green_font} 4.${Font} 停止 aria2
 ${Green_font} 5.${Font} 安装 自动上传脚本
 ${Green_font} 6.${Font} 卸载 自动上传脚本
 ${Green_font} 7.${Font} 上传脚本OneDrive 重新授权
"
read -e -p " 请输入数字 [1-7]:" num

case "$num" in
	1)
	 aria2_install  #安装
	;;
	2)
	 uninstall_aria2  #卸载
	;;
	3)
	 restart_aria2   #重启
	;;
	4)
	 stop_aria2 #停止
	;;
	5)
	 install_autoUpload #安装上传脚本
	;;
	6)
	 uninstall_autoUpload #卸载自动上传脚本
	;;
	7)
	 goto_auth #安装上传脚本
	;;
	*)
	 echo "请输入正确数字 [1-7]"
	;;
esac
fi
