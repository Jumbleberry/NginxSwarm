sudo apt-get update
sudo apt-get install build-essential zlib1g-dev libpcre3 libpcre3-dev unzip

cd pcre-8.39
./configure
make
sudo make install
cd ../

cd zlib-1.2.8
./configure
make
sudo make install
cd ../

cd openssl-1.0.2h
patch -d . -p 1 < ../nginx_chacha.patch
./config --prefix=/usr
make
sudo make install
cd ../

NPS_VERSION=1.11.33.3
wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip -O release-${NPS_VERSION}-beta.zip
unzip release-${NPS_VERSION}-beta.zip
cd ngx_pagespeed-release-${NPS_VERSION}-beta/
wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz
tar -xzvf ${NPS_VERSION}.tar.gz  # extracts to psol/
cd ../

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
--with-openssl=/root/openssl \
--user=www-data \
--group=www-data \
--add-module=/home/vagrant/nginx/ngx_pagespeed-release-${NPS_VERSION}-beta ${PS_NGX_EXTRA_FLAGS} 
make
sudo make install