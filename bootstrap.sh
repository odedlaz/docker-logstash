perl -p -i -e 's/ES_HOST/'"$ES_PORT_9200_TCP_ADDR"'/g' conf.d/logstash.conf
bin/logstash -f conf.d/logstash.conf
