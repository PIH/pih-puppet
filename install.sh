#! /bin/bash

#puppet module install saz-sudo

puppet apply -v \
  --detailed-exitcodes \
  --logdest=console \
  --logdest=syslog \
  --hiera_config=./hiera.yaml \
  --modulepath=./modules \
  --graph \
  manifests/site.pp
