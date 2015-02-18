# Bootvar

Simple library for reading MirageOS unikernel boot parameters from Xen.

To send boot parameters to the unikernel you can either add them as options in the "extra=" field in the .xl-file, like this:

```
extra="key1=val1 key2=val2"
```

.. or add them when starting the unikernel from the command line:

```
sudo xl create unikernel.xl 'extra="key1=val1 key2=val2"'
```

Bootvar was originally a part of [mirage-mimic](http://github.com/MagnusS/mirage-mimic), but is now released as a separate library. 

## License
Bootvar is published under the ISC license. See [LICENSE](LICENSE) for details.

