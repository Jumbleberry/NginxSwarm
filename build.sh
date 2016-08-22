sudo apt-get update
sudo apt-get install -y build-essential zlib1g-dev libpcre3 libpcre3-dev unzip

wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.39.tar.gz
tar -zxf pcre-8.39.tar.gz
cd pcre-8.39
./configure
make
sudo make install
cd ../

wget http://zlib.net/zlib-1.2.8.tar.gz
tar -zxf zlib-1.2.8.tar.gz
cd zlib-1.2.8
./configure
make
sudo make install
cd ../

wget http://www.openssl.org/source/openssl-1.0.2h.tar.gz
tar -zxf openssl-1.0.2h.tar.gz
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

wget http://nginx.org/download/nginx-1.9.7.tar.gz
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