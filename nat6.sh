#/bin/ash

# Wait until IPv6 route is up...                  等待路由器获取ipv6地址
line=0
while [ $line -eq 0 ]
do
        sleep 5
        line=`route -A inet6 | grep ::/0 | awk 'END{print NR}'`
done

# Add masquerading rule (NAT6) to the firewall                       将IP伪装（NAT）添加到ip6tables
ip6tables -t nat -I POSTROUTING -s `uci get network.globals.ula_prefix` -j MASQUERADE

# Set default gateway for requests to global addresses                   为LAN的全球地址请求设置默认网关
route -A inet6 add 2000::/3 `route -A inet6 | grep ::/0 | awk 'NR==1{print "gw "$2" dev "$7}'`

# Set accept_ra to 2, otherwise temporary addresses won't work                   将accept_ra(RA:Router Advertisement)设置为2，否则这里获取的临时地址不能正常工作，原话翻译，我没太明白
echo 2 > /proc/sys/net/ipv6/conf/`route -A inet6 | grep ::/0 | awk 'NR==1{print $7}'`/accept_ra

# Use temporary addresses (IPv6 privacy extensions)               使用临时地址（IPv6隐私扩展）
echo 2 > /proc/sys/net/ipv6/conf/`route -A inet6 | grep ::/0 | awk 'NR==1{print $7}'`/use_tempaddr
