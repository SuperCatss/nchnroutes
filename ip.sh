#!/bin/bash

# 指定 DNS 服务器的IP地址
dns_server="192.168.2.3"

# 创建一个临时文件来存储提取的结果
temp_file="temp.txt"

while IFS= read -r line
do
    if [[ $line == \#* ]]; then
        # 如果行以 '#' 开头（即注释行），跳过不处理
        continue
    elif [[ $line == ip:* ]]; then
        # 如果行以 'ip:' 开头，使用 ':' 作为分隔符提取 IP 地址并存储到临时文件
        ip=$(echo "$line" | awk -F ':' '{print $2}')
        
        # 检查IP地址是否为CIDR表示方法，如果不是则追加内容为ip/32
         if [[ ! $ip == *"/"* ]]; then
             ip="$ip/32"
         fi
        
        echo "$ip" >> "$temp_file"
    elif [[ $line == domain:* ]]; then
        # 如果行以 'domain:' 开头，使用 ':' 作为分隔符提取域名并存储到临时文件
        domain=$(echo "$line" | awk -F ':' '{print $2}')
        
        # 使用 nslookup 命令指定特定的 DNS 服务器解析域名，并将所有 IP 地址追加到临时文件
        resolved_ips=$(nslookup "$domain" "$dns_server" | awk '/Address: / { print $2 }')
        
        # 格式化每个解析出的IP为CIDR表示方法
        while read -r resolved_ip; do
            echo "$resolved_ip/32" >> "$temp_file"
            # echo "$resolved_ip" >> "$temp_file"
        done <<< "$resolved_ips"
    fi
done < input.txt

# 在完成文件读取后，将临时文件追加到目标文件
cat "$temp_file" >> /root/nchnroutes/china_ip_list.txt

# 删除临时文件
rm "$temp_file"

