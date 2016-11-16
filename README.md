[etcd](https://github.com/coreos/etcd) is a highly-available key value store for shared configuration and service discovery. Hiera-etcd provides a Hiera backend which allows for specifying multiple etcd paths from which data can be collected and easily inserted into Puppet manifests.

## Prerequisites

You'll need the [etcd](https://github.com/ranjib/etcd-ruby) gem
installed. Potentially with `gem install etcd`


## Configuration

The following hiera.yaml should get you started.

    :backends:
      - etcd
     
    :http:
      :host: 127.0.0.1
      :port: 4001
      :paths:
        - /configuration/%{fqdn}
        - /configuration/common

## SSL Configuration

    :backends:
      - etcd

    :http:
      :host: 127.0.0.1
      :port: 2379
      :use_ssl: true
      :ssl_ca_cert: /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem

## SSL Configuration with Client Authentication

    :backends:
      - etcd

    :http:
      :host: 127.0.0.1
      :port: 2379
      :use_ssl: true
      :ssl_ca_cert: /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
      :ssl_cert: /etc/pki/tls/certs/localhost.crt
      :ssl_key: /etc/pki/tls/private/localhost.key
 

## Thanks

The starting point for this backend was the [hiera-http](https://github.com/crayfishx/hiera-http) backend from @crayfishx.
