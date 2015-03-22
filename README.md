## LogStash Dockerfile


This repository contains a **Dockerfile** of [LogStash](http://logstash.net/) for [Docker](https://www.docker.com/).


### Base Docker Image

* [dockerfile/java:oracle-java8](https://registry.hub.docker.com/u/dockerfile/java/)


### Installation

1. Install [Docker](https://www.docker.com/).

2. Download [automated build](https://registry.hub.docker.com/u/sxoded/logstash) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull sxoded/logstash`

3. create a mountable ssl-certs directory `<ssl-dir>` on the host.

4. create a private & certs directory: `mkdir -p <ssl-dir>/certs && mkdir -p <ssl-dir>/private`

5. generate an SSL certificate for LogStash lumberjack: `cd <ssl-dir> | openssl req -subj '/CN=<hostname_of_computer_running_docker>/' -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt`

6. configure LogStash-Forwarder to use the generates certificate. example:
```json
{
  "network": {
    "servers": [ "localhost:5000" ],
    "ssl ca": "<ssl-dir>/certs/logstash-forwarder.crt",
    "timeout": 15
  },
  "files": [ { "paths": [ "/tmp/*.log" ] } ]
}
```
 
alternatively, you can build an image from Dockerfile:
 `docker build -t="sxoded/logstash" github.com/sxoded/logstash`)

### Usage

```sh
docker run -d --link <your_es_container_name>:es -p 8200:8200 -p 5000:5000 -v <ssl-dir>:/etc/pki/tls sxoded/logstash
```
 
 * the default config file uses port 8200 for incoming tcp and port 5000 for lumberjack.
 * to see LogStash in action consider running the container in interactive mode, e.g: replace `-d` with `-ti`
	
#### Replace default configuration file

  1. Create a mountable configuration directory `<config-dir>` on the host.

  2. Create LogStash config file at `<config-dir>/logstash.conf` (this following is the default):

    ```yml
	input {
	  lumberjack {
	    port => 5000
	    type => "docker"
	    ssl_certificate => "/etc/pki/tls/certs/logstash-forwarder.crt"
	    ssl_key => "/etc/pki/tls/private/logstash-forwarder.key"
	  }
	  tcp {
	    port => 8200
	    codec => json
	  }
	}
	
	filter {
	  if [type] == "docker" {
	    json {
	      source => "message"
	    }
	    mutate {
	      rename => [ "log", "message" ]
	    }
	    date {
	      match => [ "time", "ISO8601" ]
	    }
	  }
	}
	
	output {
	  stdout {
	    codec => rubydebug
	  }
	
	  elasticsearch {
	    host => "ES_HOST"
	    port => "9300"
	    protocol => "transport"
	  }
	}
    ```

  3. Start a container by mounting data directory and specifying the custom configuration file:

    ```sh
docker run -d --link elasticsearch:es -p 8200:8200 -p 5000:5000 -v <ssl-dir>:/etc/pki/tls -v <config-dir>:/opt/logstash/config.d  sxoded/logstash
    ```
