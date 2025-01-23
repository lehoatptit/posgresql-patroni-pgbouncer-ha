# Use official Postgres image as base
FROM docker.io/library/postgres:14

# Install necessary utilities and libraries
RUN export DEBIAN_FRONTEND=noninteractive \
    && echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > /etc/apt/apt.conf.d/01norecommend \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y apt-utils procps curl jq dnsutils \
    python3-pip python3-setuptools python3-distutils python3-psutil locales python3-venv \
    tzdata \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    # Clean up to reduce image size
    && apt-get remove -y python3-pip python3-setuptools \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /root/.cache

# Set timezone to GMT+7 (Asia/Ho_Chi_Minh)
RUN ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

# Create a virtual environment and install Patroni and dependencies
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip \
    && /opt/venv/bin/pip install psycopg2-binary patroni[etcd] click tzlocal cdiff pysocks \
    && mkdir -p /home/postgres \
    && chown postgres:postgres /home/postgres \
    # Clean up unnecessary files
    && rm -rf /root/.cache

#Install patronictl command inside container 
RUN ln -s /opt/venv/bin/patronictl /usr/local/bin/patronictl \
    && ln -s /opt/venv/bin/patroni /usr/local/bin/patroni \
    && ln -s /opt/venv/bin/psql /usr/local/bin/psql  

# Add the entrypoint script to the container
ADD entrypoint.sh /entrypoint.sh

# Create necessary directories and set permissions
RUN mkdir -p /data /etc/patroni && touch /etc/patroni/pgpass /etc/patroni/patroni.yml \
    && chown postgres:postgres -R /etc/patroni /data /tmp /var/run /var/lib /var/log

# Expose required ports
EXPOSE 2379 5432 8008

# Create volumes for persistent data
VOLUME /data
VOLUME /etc/patroni

# Copy the patroni configuration file and set permissions
COPY patroni.yml /etc/patroni/patroni.yml
RUN chown postgres:postgres /etc/patroni/patroni.yml \
    && chmod 755 /etc/patroni/patroni.yml

# Set locale environment variables
ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Set the entrypoint and user
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
USER postgres

