[etcd](https://github.com/coreos/etcd) is a highly-available key value store for shared configuration and service discovery. Hiera-etcd provides a Hiera backend which allows for specifying multiple etcd paths from which data can be collected and easily inserted into Puppet manifests.

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


## Outstanding

* No support for HTTPS yet
* No support for etcd server disappearing
* No tests

I'll likely swap out the Net::HTTP implementation for one using [etcd-rb](https://github.com/iconara/etcd-rb) which should make doing the right thing easier.


## Thanks

The starting point for this backend was the [hiera-http](https://github.com/crayfishx/hiera-http) backend from @crayfishx.
