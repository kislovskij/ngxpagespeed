FROM google/debian:wheezy
MAINTAINER David Gageot <david@gageot.net>

ENV DEBIAN_FRONTEND noninteractive

# From instructions here: https://github.com/pagespeed/ngx_pagespeed

# Install dependencies
RUN apt-get update -qq 
RUN apt-get install -yqq build-essential zlib1g-dev libpcre3 libpcre3-dev openssl libssl-dev libperl-dev wget zip ca-certificates

# Download ngx_pagespeed
RUN cd /tmp && wget -q -O - https://github.com/pagespeed/ngx_pagespeed/archive/v1.8.31.4-beta.tar.gz | tar zxf -
RUN cd /tmp/ngx_pagespeed-1.8.31.3-beta/ && wget -q -O - https://dl.google.com/dl/page-speed/psol/1.8.31.4.tar.gz | tar zxf -

# Download and build nginx
RUN cd /tmp && wget -q -O - http://nginx.org/download/nginx-1.7.4.tar.gz | tar zxf -
RUN cd /tmp/nginx-1.7.4 \
	&& ./configure --prefix=/etc/nginx/ --sbin-path=/usr/sbin/nginx --add-module=/tmp/ngx_pagespeed-1.8.31.4-beta --with-http_ssl_module --with-http_spdy_module \
	&& make install

# Cleanup
RUN rm -Rf /tmp/ngx_pagespeed-1.8.31.4-beta
RUN rm -Rf /tmp/nginx-1.7.4

EXPOSE 80
EXPOSE 443

VOLUME ["/etc/nginx/sites-enabled"]
WORKDIR /etc/nginx/
CMD ["/usr/sbin/nginx"]

# Configure nginx
COPY nginx.conf /etc/nginx/conf/nginx.conf
