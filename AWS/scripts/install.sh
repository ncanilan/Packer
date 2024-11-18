sudo yum -y install wget mlocate net-tools bind-utils nmap telnet cloud-utils-growpart fontconfig plymouth plymouth-plugin-script stunnel dmidecode tuned unzip jq
sudo yum -y install https://aclalvyum.alvaria.com/alvaria-release-latest.rpm
sudo rm -rf /etc/yum.repos.d/*
sudo wget https://aclalvyum.alvaria.com/alvaria-almalinux.repo -O /etc/yum.repos.d/alvaria.repo
sudo yum -y --enablerepo="alvaria-cx23" install alvaria-cx-install
