produce:
	git pull
	curl -o delegated-apnic-latest https://ftp.apnic.net/stats/apnic/delegated-apnic-latest
	curl -o china_ip_list.txt https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt
	bash ./ip.sh
	python3 produce.py 
	mv routes4.conf /etc/routes4.conf
	# mv routes6.conf /etc/routes6.conf
	# sudo birdc configure
	/etc/init.d/bird4 reload
	# sudo birdc6 configure
