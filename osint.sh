#!/bin/bash

usage() {
    echo "Usage: "
    echo "  -l    指定包含资产的文件"
    echo "  -h    帮助说明"
    exit 1
}

loadColors() {
    RED="\e[31m"
    NORMAL="\e[0m"
    YELLOW="\e[93m" 
    GREEN="\e[32m" 
    BLUE="\e[34m"
    PUR="\e[35m" #紫色
}

logo() {
    loadColors
    echo -e "${YELLOW}                      __ __   
  ______ ____  ____  |__|  |  v_1.0
 /  ___//    \ \__ \ |  |  |  
 \___ \|   |  \/ __ \|  |  |__
/____  >___|  (___  /|__|____/
     \/     \/    \/         
${YELLOW} Recon_Snail  coded by ${YELLOW}@xxy ${NORMAL}
"
}
logo


# 定义旋转图标
function rotating_spinner {
    local running=true
    local message=$1

    while $running
    do
        printf "\r[ + ] ${message}, Please Wait ... "
        sleep 0.1
        printf "\r[ x ] ${message}, Please Wait ... "
        sleep 0.1
        printf "\r[ + ] ${message}, Please Wait ... "
        sleep 0.1
        printf "\r[ x ] ${message}, Please Wait ... "
        sleep 0.1
        printf "\r[ + ] ${message}, Please Wait ... "

        # 检查容器是否正在运行
	if [ $# -gt 0 ] && ! docker ps | grep -q "${!#}"; then #传入最后一个参数，比如：     trap ' handle_sigint "$ancestor1" "$ancestor2" ' SIGINT 传入就是$ancestor2变量
            	running=false
        fi

    done &	# 让 rotating_spinner 后台运行，为了后面可以用 wait 命令阻塞执行，等待rotating_spinner执行后再向下运行
}


# 定义 CTRL+C 中断信号
# 最多可以传入2个参数   比如：  trap ' handle_sigint "$ancestor1" "$ancestor2" ' SIGINT
function handle_sigint {
    sleep 0.5

    # 获取第一个传入参数的镜像id，以extract_ip_url()为例子，即 ayuxy/tools-morefind的镜像id
    image_id=$(docker ps --filter "ancestor=$1" --format "{{.ID}}" 2>/dev/null)	
    	# 如下为：检查逻辑的测试代码     
    	#printf "传入的参数：$1\n"   	
   	#printf "镜像: $image_id\n"	
    
    # 如果第一个参数的镜像id为空，也就表示ayuxy/tools-morefind并没有在运行，随机获取第二个传入参数ayuxy/tools-httpx的镜像id	
    if [ -z "$image_id" ] && [ -n "$2" ]; then
        image_id=$(docker ps --filter "ancestor=$2" --format "{{.ID}}" 2>/dev/null)
    	# 如下为：检查逻辑的测试代码        
    	#printf "传入的参数：$2\n"   	
   	#printf "镜像: $image_id\n"	
    fi

    # 如果第二个传入参数ayuxy/tools-httpx的镜像id也为空，那么两个传入参数的镜像id都为空，大概是因为ayuxy/tools-morefind瞬间就执行完成，且ayuxy/tools-httpx还没执行
    if [ -z "$image_id" ]; then
        image_id="0000"		#把镜像id设置成 0000，来表示这种特殊情况。如果不设置，那么 image_id 就为空，用 docker ps | grep -q "$image_id" 查询的时候，也就是查询的"$image_id"为空的容器，而此时查询的结果也是空，所以会错误的认为查询成功，也就是还有镜像在运行，这样就导致执行打印 printf "\n\r[${RED}FAL${NORMAL}] Forced Quit" 语句
    	# 如下为：检查逻辑的测试代码   	
   	#printf "镜像: $image_id\n"	
    fi
    	
    	# 如下为：检查逻辑的测试代码
    	#printf "\n======  关闭容器前：====================="   
    	#printf "\ndocker ps结果如下：\n"       		
	#docker ps
    	#printf "\ndocker ps | grep -q image_id 的返回结果 status 如下：（容器不存在返回status=1，存在返回status=0）\n" 
    	#docker ps | grep -q "$image_id"
	#status=$?
	#printf "status: $status"	
    	#printf "\n======================================\n\n" 
    	
    if [ -n "$image_id" ]; then
        docker kill $image_id > /dev/null 2>&1
    fi
	
    sleep 0.5
    	
    	# 如下为：检查逻辑的测试代码
    	#printf "\n======  关闭容器后：====================" 
    	#printf "\ndocker ps | grep -q image_id 的返回结果 status 如下：（容器不存在返回status=1，存在返回status=0）\n"     	
	#docker ps | grep -q "$image_id"
	#status=$?
	#printf "status: $status"
    	#printf "\n===========================================\n" 

    if ! docker ps | grep -q "$image_id"; then
        printf "\n\r[${RED}FAL${NORMAL}] Forced Quit"
    fi

    exit 1
}



# step1 分拣主域名 
extract_ip_url() {    

    line_count=$(cat "$input_file" | wc -l)
    echo -e "[${GREEN}INF${NORMAL}] Load ${YELLOW}$line_count ${NORMAL}pieces of data "
    
    printf "\r[${PUR}STP${NORMAL}] Executing the content of Step1 as follows\n"   
    printf "\r[${GREEN}INF${NORMAL}] Enumerating Domain from ${YELLOW}$input_file${NORMAL}, Scan with Morefind and Httpx \n"   
    
    ancestor1="ayuxy/tools-morefind"
    ancestor2="ayuxy/tools-httpx"
    trap ' handle_sigint "$ancestor1" "$ancestor2" ' SIGINT

    spinner_message="Scanning with MoreFind and Httpx"
    container_name1="ayuxy/tools-morefind"
    container_name2="ayuxy/tools-httpx"    
    # 调用旋转图标函数，并传递自定义的提示消息和容器名称
       
    
    # 分拣文件中的根域名
    screen -dmS morefind bash -c "./CyberX exec morefind -d --root -f $input_file -o Root_Domain.txt"	 # 注意：screen 是新打开一个终端，完全不能用 wait来阻塞
    rotating_spinner "$spinner_message" "$container_name1" 	# 开始执行 rotating_spinner，该函数会一直在后台执行，直到 ayuxy/tools-morefind 容器执行结束后rotating_spinner才会停止运行。注意：在后台执行rotating_spinner后，shell脚本会继续向下运行 ，此处是执行 wait
    wait		# 然后执行 wait，执行 wait 后发现当前shell脚本的后台中存在 rotating_spinner一直在执行，所以会阻塞，等待完 rotating_spinner 函数执行结束后，才会继续向下执行 shell 脚本。 如果没有这个 wait，那么很可能 当 screen -dmS morefind bash -c '' 没有执行完，shell脚本就继续向下执行其它内容了，容易出现问题。
     
    # 分拣文件中的主域名
    if [ -e "Root_Domain.txt" ]; then
        printf "\r[${YELLOW}RES${NORMAL}] Scan Root-Domain with MoreFind, Result in Root_Domain.txt\n"
        screen -dmS morefind bash -c "./CyberX exec morefind -d -f $input_file -o Domain.txt "
        rotating_spinner "$spinner_message" "$container_name1" 
	wait
    else
    	printf "\r[${RED}ERR${NORMAL}] Scan Root-Domain with MoreFind, But no Output, Please Check shell_Script\n"
    fi  
    
    # 用 httpx 测试域名  morefind_result 里面的主域名是否有效    
    if [ -e "Domain.txt" ]; then
        printf "\r\033[0K[${YELLOW}RES${NORMAL}] Scan Domain with MoreFind, Result in Domain.txt\n"      # \033[K 可以在输出消息前先清空一行，然后再输出消息，避免出现重叠问题。由于该消息太短并且与 Please Wait .. 重叠，会打印 Scan Domain with MoreFind, Result in Domain.txt.. 多出了两个点
	screen -dmS httpx bash -c " ./CyberX exec httpx -l Domain.txt -o Domain_alive.txt "
	rotating_spinner "$spinner_message" "$container_name2" 
	wait
    else
    	printf "\r[${RED}ERR${NORMAL}] Scan Domain with MoreFind, But no Output, Please Check shell_Script\n"
    fi               	   
    
    wait  # 这个wait其实是等待 rotating_spinner 一直函数旋转结束，通过该函数旋转结束进而判断docker程序运行结束，此处就是 ayuxy/tools-httpx
    
    # 检查Domain_alive.txt文件是否存在
    if [ -e "Domain_alive.txt" ]; then
	printf "\r[${YELLOW}RES${NORMAL}] Scan Domain-Alive with Httpx, Result in Domain_alive.txt\n"
	printf "\r[${GREEN}INF${NORMAL}] Scan Done with MoreFind and Httpx, Continue executing other step\n"	
    else
	printf "\r[${RED}ERR${NORMAL}] Scan done with MoreFind, But not File, Please Check shell_Script\n"
    fi
}




# step 2 收集子域名 
extract_domains() {
    
    printf "\r[${PUR}STP${NORMAL}] Executing the content of Step2 as follows\n"  
    printf "\r[${GREEN}INF${NORMAL}] Enumerating Subdomains from ${YELLOW}Root_Domain.txt${NORMAL}, Scan with Subfinder and Httpx\n"   
    
    ancestor1="ayuxy/tools-subfinder"
    trap ' handle_sigint  "$ancestor1" ' SIGINT

    spinner_message="Scanning with Subfinder and Httpx"    
    container_name1="ayuxy/tools-subfinder"
    container_name2="ayuxy/tools-httpx"    
    
    screen -dmS subfinder bash -c "./CyberX exec subfinder -dL Root_Domain.txt -o Subdomains.txt "    
    rotating_spinner "$spinner_message" "$container_name1"    	
    wait 

    if [ -e "Subdomains.txt" ]; then
        printf "\r\033[0K[${YELLOW}RES${NORMAL}] Scan Subdomains with Subfinder, Result in Subdomains.txt\n"      
	screen -dmS httpx bash -c " ./CyberX exec httpx -l Subdomains.txt -o Subdomains_alive.txt "
	rotating_spinner "$spinner_message" "$container_name2" 
	wait
    else
    	printf "\r[${RED}ERR${NORMAL}] Scan Subdomains with Subfinder, But no Output, Please Check shell_Script\n"
    fi    


    if [ -e "Subdomains_alive.txt" ]; then
        printf "\r\033[0K[${YELLOW}RES${NORMAL}] Scan Subdomains-Alive with Subfinder, Result in Subdomains_alive.txt\n"   
	printf "\r[${GREEN}INF${NORMAL}] Scan Done with MoreFind and Httpx, Continue executing other step\n"	           
    else
    	printf "\r[${RED}ERR${NORMAL}] Scan Subdomains-Alive with Subfinder, But no Output, Please Check shell_Script\n"
    fi    


   

}






# 解析命令行参数
while getopts ":l:h" opt; do
    case ${opt} in
        l )
            input_file=${OPTARG}
            ;;
        h )
            usage
            ;;
        \? )
            echo "Invalid option: -${OPTARG}" 1>&2
            usage
            ;;
        : )
            echo "Option -${OPTARG} requires an argument" 1>&2
            usage
            ;;
    esac
done
shift $((OPTIND -1))



# 如果没有指定文件，则使用默认文件
if [ -z "$input_file" ]; then
    echo "请指定资产文件"
fi


# 提取IP和URL，并去重
if [ -n "$input_file" ]; then
    extract_ip_url
    extract_domains
fi
