FROM postgres:9.4
MAINTAINER Eric Rasche <rasche.eric@yandex.ru>

ENV DEBIAN_FRONTEND noninteractive

# TODO: Pulled from webapollo docker image, some of these may be extraneous (I
# think the heap stuff.) Installed most from apt for ease of installation
RUN apt-get -qq update && \
    apt-get install --no-install-recommends -y subversion build-essential \
    libpng-dev zlib1g zlib1g-dev build-essential make libpq-dev libperlio-gzip-perl \
    libcapture-tiny-perl libtest-differences-perl libperlio-gzip-perl \
    libdevel-size-perl libdbi-perl libjson-perl libjson-xs-perl libheap-perl \
    libhash-merge-perl libdbd-pg-perl libio-string-perl libtest-most-perl \
    libarray-compare-perl libconvert-binary-c-perl libgraph-perl \
    libgraphviz-perl libsoap-lite-perl libsvg-perl libsvg-graph-perl \
    libset-scalar-perl libsort-naturally-perl libxml-sax-perl libxml-twig-perl \
    libxml-writer-perl libyaml-perl libgd2-xpm-dev curl xsltproc

# TODO: fix certs
RUN svn co --non-interactive --trust-server-cert https://svn.code.sf.net/p/gmod/svn/schema/trunk/chado /chado/

WORKDIR /chado/

ENV OBO_ONTOLOGIES 1,2,3,4,5
ENV CHADO_DB_NAME postgres
ENV CHADO_DB_HOST localhost
ENV CHADO_DB_PORT 5432
ENV CHADO_DB_USERNAME postgres
ENV CHADO_DB_PASSWORD postgres
# Must set postgres DB env password, so it'll be recognised on startup and set
# whenever the user starts the container, as we use the original docker
# postgres:9.4 CMD
ENV POSTGRES_PASSWORD postgres
ENV GMOD_ROOT /usr/share/gmod/

RUN mkdir -p $GMOD_ROOT

RUN curl -L http://cpanmin.us | perl - App::cpanminus
# Some have to be forced.
RUN cpanm --force Test::More Heap::Simple Heap::Simple::XS DBIx::DBStag
# But most install just fine
RUN cpanm DBI Digest::Crc32 Cache::Ref::FIFO URI::Escape HTML::Entities \
    HTML::HeadParser HTML::TableExtract HTTP::Request::Common LWP XML::Parser \
    XML::Parser::PerlSAX XML::SAX::Writer XML::Simple Data::Stag \
    Error PostScript::TextBlock Spreadsheet::ParseExcel Algorithm::Munkres \
    BioPerl Bio::GFF3::LowLevel::Parser File::Next CGI DBD::Pg SQL::Translator \
    Digest::MD5 Text::Shellwords Module::Build Class::DBI Class::DBI::Pg \
    Class::DBI::Pager Template Bio::Chado::Schema GD GO::Parser

RUN perl Makefile.PL GMOD_ROOT=/usr/share/gmod/  DEFAULTS=1 RECONFIGURE=1
RUN make && make install

# Have to set postgres password, so things can connect
# TODO: remove now that chado-postgres-prebuild and exec-with-db no longer
# depend on NC to wait for DB to come up
RUN apt-get install -y netcat

RUN mkdir -p /var/lib/postgresql/9.4/
ENV PGDATA /var/lib/postgresql/9.4/
# Taken from /docker-entrypoint.sh and removed command to actually start the DB
ADD ./chado-postgres-prebuild.sh /chado-postgres-prebuild.sh
RUN /chado-postgres-prebuild.sh postgres

# Script to wrap commands that need to be done with the DB running (and should
# shut the DB down when they're done)
ADD ./exec_with_db.sh /exec_with_db.sh
RUN /exec_with_db.sh make load_schema
RUN /exec_with_db.sh make prepdb
# This is just a version of exec_with_db except it has the command hardcoded
# because it was too much work to figure out how to echo "1,2,3,4,5" to `make
# ontologies`.
ADD ./load_ontologies.sh /chado/load_ontologies.sh
# Wait 5 hours ...
RUN /chado/load_ontologies.sh
