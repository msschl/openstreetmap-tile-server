FROM ubuntu:18.04

# Set up environment
ENV TZ=UTC
ENV AUTOVACUUM=on
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update \
  && apt-get install wget gnupg2 lsb-core -y \
  && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && echo "deb [ trusted=yes ] http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list \
  && apt-get update \
  && apt-get install -y apt-transport-https ca-certificates \
  && apt-get install -y --no-install-recommends --allow-unauthenticated \
  build-essential \
  gcc \
  gdal-bin \
  libagg-dev \
  libboost-filesystem-dev \
  libboost-system-dev \
  libbz2-dev \
  libexpat1-dev \
  libfreetype6-dev \
  libgdal-dev \
  libgeos++-dev \
  libgeos-dev \
  libgeotiff-epsg \
  libicu-dev \
  libpq-dev \
  libproj-dev \
  libprotobuf-c0-dev \
  libtiff5-dev \
  libtool \
  libxml2-dev \
  make \
  postgis \
  postgresql-12 \
  postgresql-contrib-12 \
  postgresql-server-dev-12 \
  sudo \
  tar \
  wget \
&& apt-get clean autoclean \
&& apt-get autoremove --yes \
&& rm -rf /var/lib/{apt,dpkg,cache,log}/

# Set up PostGIS
RUN wget http://download.osgeo.org/postgis/source/postgis-3.0.0.tar.gz -O postgis.tar.gz \
 && mkdir -p postgis_src \
 && tar -xvzf postgis.tar.gz --strip 1 -C postgis_src \
 && rm postgis.tar.gz \
 && cd postgis_src \
 && ./configure && make && make install \
 && cd .. && rm -rf postgis_src

# Configure PosgtreSQL
COPY postgresql.custom.conf.tmpl /etc/postgresql/12/main/
RUN chown -R postgres:postgres /var/lib/postgresql \
 && chown postgres:postgres /etc/postgresql/12/main/postgresql.custom.conf.tmpl \
 && echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/12/main/pg_hba.conf \
 && echo "host all all ::/0 md5" >> /etc/postgresql/12/main/pg_hba.conf

# Start running
COPY run.sh /
ENTRYPOINT ["/run.sh"]
CMD []

EXPOSE 5432