sudo apt-get update
sudo apt-get install -y build-essential zlib1g-dev libpcre3 libpcre3-dev unzip

wget https://github.com/Jumbleberry/NginxSwarm/blob/master/zlib-1.2.8.tar.gz?raw=true
tar -zxf pcre-8.39.tar.gz
cd pcre-8.39
./configure
make
sudo make install
cd ../

wget https://github.com/Jumbleberry/NginxSwarm/blob/master/pcre-8.39.tar.gz?raw=true
tar -zxf zlib-1.2.8.tar.gz
cd zlib-1.2.8
./configure
make
sudo make install
cd ../

wget https://github.com/Jumbleberry/NginxSwarm/blob/master/openssl-1.0.2h.tar.gz?raw=true
tar -zxf openssl-1.0.2h.tar.gz
cd openssl-1.0.2h
patch -d . -p 1 < ../nginx_chacha.patch
./config --prefix=/usr
make
sudo make install
cd ../

NPS_VERSION=1.11.33.3
wget https://github.com/Jumbleberry/NginxSwarm/blob/master/release-1.11.33.3-beta.zip?raw=true
unzip release-${NPS_VERSION}-beta.zip
cd ngx_pagespeed-release-${NPS_VERSION}-beta/
wget https://github.com/Jumbleberry/NginxSwarm/blob/master/1.11.33.3.tar.gz?raw=true
tar -xzvf ${NPS_VERSION}.tar.gz  # extracts to psol/
cd ../

wget https://github.com/Jumbleberry/NginxSwarm/blob/master/nginx-1.9.7.tar.gz?raw=true
tar -zxf nginx-1.9.7.tar.gz
CURPATH=$(readlink -f . | sed -r 's/^.{1}//');
cd nginx-1.9.7/
patch -d . -p 1 < ../nginx_dynamic_tls.patch
patch -d . -p 1 < ../nginx_http2_spdy.patch
./configure \
--sbin-path=/etc/nginx/nginx \
--conf-path=/etc/nginx/nginx.conf \
--pid-path=/etc/nginx/nginx.pid \
--with-pcre=../pcre-8.39 \
--with-zlib=../zlib-1.2.8 \
--with-http_ssl_module \
--with-stream \
--with-http_spdy_module \
--with-http_v2_module \
--with-threads \
--with-file-aio \
--with-openssl=/${CURPATH}/openssl-1.0.2h \
--user=www-data \
--group=www-data \
--add-module=/${CURPATH}/ngx_pagespeed-release-${NPS_VERSION}-beta ${PS_NGX_EXTRA_FLAGS} 
make
sudo make install
cd ../


cp nginx.conf /etc/init/nginx.conf
initctl reload-configuration
initctl start nginx