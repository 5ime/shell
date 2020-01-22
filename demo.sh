#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH


sh_ver="2.0.0"




#0升级脚本
Update_Shell(){
	sh_new_ver=$(wget --no-check-certificate -qO- -t1 -T3 "https://raw.githubusercontent.com/veip007/hj/master/hj.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1) && sh_new_type="github"
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} 无法链接到 Github !" && exit 0
	wget -N --no-check-certificate "https://raw.githubusercontent.com/veip007/hj/master/hj.sh" && chmod +x hj.sh
	echo -e "脚本已更新为最新版本[ ${sh_new_ver} ] !(注意：因为更新方式为直接覆盖当前运行的脚本，所以可能下面会提示一些报错，无视即可)" && exit 0
}
 #1安装BBR 锐速
bbr_ruisu(){
	wget -N --no-check-certificate https://raw.githubusercontent.com/5ime/shell/master/caddy_install.sh && chmod +x caddy_install.sh && bash caddy_install.sh
}
#2谷歌 BBR2 BBRV2
Google_bbr2(){
	wget -N --no-check-certificate https://raw.githubusercontent.com/yeyingorg/bbr2.sh/master/bbr2.sh && chmod +x bbr2.sh && bash bbr2.sh
}
#3安装KCPtun
Kcptun(){
	wget -N --no-check-certificate https://github.com/veip007/Kcptun/raw/master/kcptun/kcptun.sh && chmod +x kcptun.sh && bash kcptun.sh
}
#4安装SSR多用户版
Install_ssr(){
	wget -N --no-check-certificate https://raw.githubusercontent.com/veip007/doubi/master/ssrmu.sh && chmod +x ssrmu.sh && bash ssrmu.sh
}
#5安装V2ary_233一键
Install_V2ray(){
	wget -N --no-check-certificate https://raw.githubusercontent.com/veip007/v2ray/master/v2.sh && chmod +x v2.sh && bash v2.sh
}
#6安装Tg专用代理
Tg_socks(){
	wget -N --no-check-certificate https://raw.githubusercontent.com/veip007/doubi/master/mtproxy_go.sh && chmod +x mtproxy_go.sh && bash mtproxy_go.sh
}
#7安装Goflyway
Install_goflyway(){
	wget -N --no-check-certificate https://git.io/goflyway.sh && chmod +x goflyway.sh && bash goflyway.sh
}
#8小鸡性能测试
View_superbench(){
	wget -N --no-check-certificate https://raw.githubusercontent.com/veip007/cesu/master/superbench.sh && chmod +x superbench.sh && bash superbench.sh
}

#9回程线路测试
View_huicheng(){
	wget -N --no-check-certificate https://raw.githubusercontent.com/veip007/huicheng/master/huicheng && chmod +x huicheng
}
#10安装云监控
Install_status(){
	wget -N --no-check-certificate https://raw.githubusercontent.com/veip007/doubi/master/status.sh && chmod +x status.sh && bash status.sh
}
#11一键DD包（OD源）
DD_OD(){
	wget -N --no-check-certificate https://raw.githubusercontent.com/veip007/dd/master/dd-od.sh && chmod +x dd-od.sh  && ./dd-od.sh
}
#12一键DD包（GD源）
DD_GD(){
	wget -N --no-check-certificate https://raw.githubusercontent.com/veip007/dd/master/dd-gd.sh && chmod +x dd-gd.sh  && ./dd-gd.sh
}
action=$1
if [[ "${action}" == "monitor" ]]; then
	crontab_monitor_goflyway
else
echo && echo -e " 
+-------------------------------------------------------------+
|                          懒人专用                           |
|                 小鸡一键管理脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}                   |                      
|                     一键在手小鸡无忧                        |
|                     欢迎提交一键脚本                        |
+-------------------------------------------------------------+

  
 ${Green_font_prefix} 0.${Font_color_suffix} 升级脚本
————————————
 ${Green_font_prefix} 1.${Font_color_suffix} 加速系列：Bbr系列、锐速
 ${Green_font_prefix} 2.${Font_color_suffix} 安装谷歌 BBR2 BBRV2
 ${Green_font_prefix} 3.${Font_color_suffix} 安装KCPtun
 ${Green_font_prefix} 4.${Font_color_suffix} 安装SSR多用户版
 ————————————
 ${Green_font_prefix} 5.${Font_color_suffix} 安装V2ary_233一键
 ${Green_font_prefix} 6.${Font_color_suffix} Tg专用代理（Go版）
 ${Green_font_prefix} 7.${Font_color_suffix} 安装Goflyway
 ${Green_font_prefix} 8.${Font_color_suffix} 小鸡性能测试
 ————————————
 ${Green_font_prefix} 9.${Font_color_suffix} 回程线路测试:命令:./huicheng 您的IP
 ${Green_font_prefix}10.${Font_color_suffix} 云监控
 ${Green_font_prefix}11.${Font_color_suffix} 傻瓜式一键DD包（OD源）
 ${Green_font_prefix}12.${Font_color_suffix} 傻瓜式一键DD包（GD源）
————————————" && echo

fi
echo
read -e -p " 请输入数字 [0-12]:" num
case "$num" in
	0)
	Update_Shell
	;;
	1)
	bbr_ruisu
	;;
	2)
	Google_bbr2
	;;
	3)
	Kcptun
	;;
	4)
	Install_ssr
	;;
	5)
	Install_V2ray
	;;
	6)
	Tg_socks
	;;
	7)
	Install_goflyway
	;;
	8)
	View_superbench
	;;
	9)
	View_huicheng
	;;
	10)
	Install_status
	;;
	11)
	DD_OD
	;;
	12)
	DD_GD
	;;
	*)
	echo "请输入正确数字 [0-12]"
	;;
esac