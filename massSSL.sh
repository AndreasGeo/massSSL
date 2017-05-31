#!/bin/bash
#Mass SSL v1.1

# -tls1 -ssl3
# Check tls1

echo -e "\n massSSL v1.0 \n\n"
echo -e "Author: superhedgy"

version=$(echo "version" | openssl | cut -f3 -d " ")

if [  "$(which openssl)" != "" ]; then
  echo -e "OpenSSL version: $version \n"
else
  echo -e "OpenSSL was not detected. Please use the --install option ./massSSL.sh --install"
  exit 1
fi

#if [ ${#} -eq 0 ]
if [ $# != 1 ]; then
  echo -e "Usage: ./massSSL.sh targets.txt \n"
  exit 1
else
  if [ $1 == '--install' ]; then
    echo "Installing dependencies..."
    wget https://www.openssl.org/source/openssl-0.9.8k.tar.gz
    tar -xvzf openssl-0.9.8k.tar.gz
    mv openssl-0.9.8k ./lib/
    cd ./lib
    ./Configure darwin64-x86_64-cc -shared
    make
    cd ./../
    rm -f openssl-0.9.8k.tar.gz
  #else
  #  echo -e "Ooops! Option $1 was not recognised \n"
  #  exit
  fi
fi

for ip in $(cat $1);
do

# Supress Bash Errors
exec 3>&2
exec 2> /dev/null

ciphers=$(openssl ciphers 'ALL:eNULL' | sed -e 's/:/ /g')

ssl2=$(echo " \n\n" | /usr/bin/openssl s_client -connect $ip:443 -ssl2&)
ssl3=$(echo " \n\n" | /usr/bin/openssl s_client -connect $ip:443 -ssl3&)
tls1=$(echo " \n\n" | /usr/bin/openssl s_client -connect $ip:443 -tls1&)
cipher1=$(echo " \n\n" | /usr/bin/openssl s_client -connect $ip:443 -cipher "DES-CBC3-SHA"&)
cipher2=$(echo " \n\n" | /usr/bin/openssl s_client -connect $ip:443 -ssl3 -cipher "RC4"&)
cipher3=$(echo " \n\n" | /usr/bin/openssl s_client -connect $ip:443 -ssl3 -cipher "EXP"&)

wait
echo -e "$ip:"
  if (echo $ssl2 | grep -q "END CERTIFICATE"); then
    echo $ip >> ssl2.txt
    echo "[+] SSL v2.0 protocol is supported"
  else
    echo "[-] SSL v2.0 protocol is NOT supported"
  fi

  if (echo $ssl3 | grep -q "END CERTIFICATE"); then
    echo $ip >> ssl3.txt
    echo "[+] SSL v3.0 protocol is supported"
  else
    echo "[-] SSL v3.0 protocol is NOT supported"
  fi

  if (echo $tls1 | grep -q "END CERTIFICATE"); then
    echo $ip >> tls1.txt
    echo "[+] TLS v1.0 protocol is supported"
  else
    echo "[-] TLS v1.0 protocol is NOT supported"
  fi

  if (echo $cipher1 | grep -q "END CERTIFICATE"); then
    echo $ip >> DES_CBC3_SHA_ciphers.txt
    echo "[+] DES-CBC3-SHA is supported"
  else
    echo "[-] DES-CBC3-SHA is NOT supported"
  fi

  if (echo $cipher2 | grep -q "END CERTIFICATE"); then
    echo $ip >> rc4.txt
    echo "[+] RC4 is supported"
  else
    echo "[-] RC4 is NOT supported"
  fi

  if (echo $cipher3 | grep -q "END CERTIFICATE"); then
      echo $ip >> exp.txt
      echo "[+] EXP is supported"
  else
      echo "[-] EXP is NOT supported"
  fi

  if (echo $cipher1 | grep -q "self signed"); then
    echo $ip >> certificates.txt
    echo "[+] Self Signed Certificate Detected"
  fi

done;
