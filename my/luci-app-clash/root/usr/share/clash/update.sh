#!/bin/sh

wget-ssl --no-check-certificate https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt -O /tmp/gfw.b64

generate_china_banned()
{
	
		cat $1 | base64 -d > /tmp/gfwlist.txt
		rm -f $1
    sed -i '/^@@|/d' /tmp/gfwlist.txt

	cat /tmp/gfwlist.txt | sort -u |
		sed 's#!.\+##; s#|##g; s#@##g; s#http:\/\/##; s#https:\/\/##;' |
		sed '/\*/d; /apple\.com/d; /sina\.cn/d; /sina\.com\.cn/d; /baidu\.com/d; /byr\.cn/d; /jlike\.com/d; /weibo\.com/d; /zhongsou\.com/d; /youdao\.com/d; /sogou\.com/d; /so\.com/d; /soso\.com/d; /aliyun\.com/d; /taobao\.com/d; /jd\.com/d; /qq\.com/d' |
		sed '/^[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+$/d' |
		grep '^[0-9a-zA-Z\.-]\+$' | grep '\.' | sed 's#^\.\+##' | sort -u |
		awk '
BEGIN { prev = "________"; }  {
	cur = $0;
	if (index(cur, prev) == 1 && substr(cur, 1 + length(prev) ,1) == ".") {
	} else {
		print cur;
		prev = cur;
	}
}' | sort -u

}

generate_china_banned /tmp/gfw.b64 > /tmp/gfw.txt
rm -f /tmp/gfwlist.txt
sed '/.*/s/.*/server=\/\.&\/127.0.0.1#5335\nipset=\/\.&\/gfwlist/' /tmp/gfw.txt >/tmp/gfwnew.txt
rm -f /tmp/gfw.txt

if [ -s "/tmp/gfwnew.txt" ];then
  if ( ! cmp -s /tmp/gfwnew.txt /etc/clash/dnsmasq_gfwlist.conf );then
    mv /tmp/gfwnew.txt /etc/clash/dnsmasq_gfwlist.conf
    rm -f /tmp/gfwnew.txt
  fi
fi