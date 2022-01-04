FROM tootsuite/mastodon:v3.4.4

# add extra packages 
USER root
RUN mkdir -p /var/cache/apt && \
    apt-get update && \
    apt-get -y --no-install-recommends install \
	  nginx && \
	apt-get clean
RUN gem install foreman
RUN rm -f /etc/nginx/sites-available/default /etc/nginx/modules-available/* && \
    mkdir -p /run/nginx/{temp,log} && \
    chown -R mastodon:mastodon /run/nginx && \
    rm -rf /var/lib/nginx /var/log/nginx && \
    ln -nsf /run/nginx/temp /var/lib/nginx && \
    ln -nsf /run/nginx/log /var/log/nginx 

# copy over our extra stuff
COPY --chown=mastodon:mastodon Procfile.* nginx*.conf /opt/mastodon
RUN mkdir -p /opt/mastodon/cache/nginx && chown -R mastodon:mastodon /opt/mastodon/cache

# reset
USER mastodon
ENV RAILS_LOG_TO_STDOUT="enabled"
ENTRYPOINT ["foreman", "start", "-f", "Procfile.web"]
