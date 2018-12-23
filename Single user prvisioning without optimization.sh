#!/usr/bin/env bash
#chmod u+x <textfile>
#use the above command to give the textfile permission to be run


#Update the machine just in case
echo "Getting updates for this machine"
apt-get update

#Install python.pip for Shadowsocks
echo "checking if this machine requires python-pip "
apt-get install python-pip <<-EOF
y
EOF

echo "installing shadowsocks"
pip install shadowsocks

#Installing cryptobox for security and speed
apt-get install python-m2crypto
apt-get install build-essential
wget https://github.com/jedisct1/libsodium/releases/download/1.0.10/libsodium-1.0.10.tar.gz
tar xf libsodium-1.0.10.tar.gz && cd libsodium-1.0.10
./configure && make && make install
ldconfig

#Een variabele definiëren om de private IP te vinden, deze wordt in het config file.json toegevoegd zodat er verbinding kan worden gemaakt
private_ip=$(ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
echo $private_ip

cd /etc
echo "Creating Config file"
#Een nieuw textbestand aanmaken voor de config van Shadowsocks
config_file_shadowsocks="shadowsocks.json"
if [ -e $config_file_shadowsocks ]; then
    echo "file" + $config_file_shadowsocks + " already exists!"
else
    #Text naar het textbestand schrijven | Hier de verschillende gegevens inzetten als die nodig zijn(poorten en wachtwoorden)
    echo '{' >> $config_file_shadowsocks
    echo '     "server":"'$private_ip'",' >> $config_file_shadowsocks
    echo '     "server_port":8000,' >> $config_file_shadowsocks
    echo '     "local_port":1080,' >> $config_file_shadowsocks
    echo '     "password":"Password1",' >> $config_file_shadowsocks
    echo '    "timeout":600,' >> $config_file_shadowsocks
    echo '    "method":"chacha20"' >> $config_file_shadowsocks
fi

#give the file permission to be ran
chmod u+x $config_file_shadowsocks

sed -i "14i /usr/bin/python /usr/local/bin/ssserver -c /etc/shadowsocks.json -d start" rc.local

cd

ssserver -c /etc/shadowsocks.json -d start
