# Changelog #

## 2016-10-16 John Anderson <ja391045@gmail.com> ##

- Added SSL configuration options to etcd client connection.
- Added a feeble attempt at casting etcd output to specific types based on content.
    - "true" or "false" strings are cast to Puppet boolean values.
    - "^[0-9]+$" strings are cast to Fixnum.
