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

The above commands check out the source code repositories required to build the iRODS server.

Our Docker container already has the iRODS externals packages installed, including a number of utlities, libraries and
dependencies that are required to build and run iRODS.  This includes recent enough versions of Clang (6.0) and
CMake (3.11) to support the C++17 language.  (Note the [externals](http://github.com/irods/externals) can also be built
from source if required.)

Also installed is the ninja builder, a `make` substitute optimized for running independed parts of a build in parallel.

## Build step

In the next step, we build the server packages and build the runtime and development components.

  - 1a
    ```
    $ cd build__irods && /opt/irods-externals/cmake3.11.4-0/bin/cmake -G Ninja ../irods
    $ ninja package
    ```
  - 1b
    ```
    $ ~/ubuntu_irods_installer/install.sh -C --w=basic 4
    ```

We then build and install the "icommands" -- client programs which are instrumental to the testing and installation of the iRODS server,
as well as for routine command-line operations and interactions with it:

  - 2a
    ```
    $ cd ../build__irods_client_icommands && /opt/irods-externals/cmake3.11.4-0/bin/cmake -G Ninja ../irods_client_icommands
    $ ninja package
    ```
  - 2b
    ```
    $ ~/ubuntu_irods_installer/install.sh -C --w=basic-skip 4 5
    ```

The last of the above commands additionally installs the server and database plugins.

Note: The robot installation script `install.sh`, though convenient, hides from us the details
Following are the individual dpkg commands extracted for the sake clarity;
this will be needed soon, in the debug phase of this tutorial, where we will enter a rapid cycle of modifying,rebuilding and testing code:

  * Step 1b can be replaced by (please excuse the KornShell/Bash wildcards!):
    ```
    $ dpkg -i ~/github/build__irods/irods-{dev,runtime}*.deb
    ```

  * Step 2b can be replaced by:
    ```
    $ dpkg -i ~/github/build__irods_client_icommands/*.deb ~/github/build__irods/irods-{server,database*postgres}*.deb
    ```
