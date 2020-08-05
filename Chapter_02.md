# Building

---

## Checking out iRODS source repositories

Within the docker container, do the following at the command line:

```
$ mkdir ~/github
$ cd ~/github
$ git clone http://github.com/irods/irods -b 4-2-stable --recursive
$ git clone http://github.com/irods/irods_client_icommands -b 4-2-stable
$ for x in irods*/ ; do mkdir build__$x; done
```

The above commands checkout the source code repositories required to build the server.
The container already has iRODS externals packages installed, including:
  *  ninja, a parallel executing substitute for `make`
  *  sufficiently recent installations of Clang (6.0) and CMake (3.11) with which to configure and build from these repositories.

Now we build the server and partially install it (actually, the runtime component first):
```
$ cd build__irods ; /opt/irods-externals/cmake3.11.4-0/bin/cmake -G Ninja
$ ninja package
$ ~/ubuntu_irods_installer/install.sh -C 4
```
and then the icommands which will be instrumental to the server's testing upon installation:
```
$ cd ../build__irods_client__icommands
$ 
```
