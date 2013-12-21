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


## Thanks

The starting point for this backend was the [hiera-http](https://github.com/crayfishx/hiera-http) backend from @crayfishx.
