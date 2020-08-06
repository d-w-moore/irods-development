# Beginning

---

## Setting up

  * 1.Log in as an administrative user on a Windows, Mac, or Linux workstation (or VM).

    (We'll need the admin access for installing software, such as (in this chapter) Docker and git -- and, later on, docker-compose and python.)

    The "missing package manager" [Homebrew](https://docs.brew.sh/Installation) may be installed on Mac machines to offer access to many convenient extras, such as 'tig', 'fish', etc.

       For the purposes of the exercise in this first chapter, please install [docker](http://docs.docker.com) and [git](http://git-scm.com) by following the the appropriate OS platform links on the respective websites.

       Of course, on Ubuntu Linux, you can simply do the following:
       ```
       sudo apt update && sudo apt install git docker.io
       ```
       and then will only need to adjust permissions for your login account to have `docker` daemon access:
       ```
       sudo usermod -aG docker [username]
       ```
       You will have to log out fully, and log back in again.  It's likely this will be sufficient; but if not, reboot the machine.
       
       You'll know docker is properly configured when you can run the following command without error :
       ```
       $ docker ps
       ```
---

## Configuring and running an iRODS server in Docker

The docker container will use a "robot" install script from this repository `install.sh` (from [here](http://github.com/d-w-moore/ubuntu_irods_installer)) designed to automate the
process of installing iRODS software packages whether remote (from an Internet repository) or local (e.g., built by the user).


  * 1.In a directory `~/github` create a local copy of this repo.
       ```
       $ mkdir ~/github ; cd ~/github ; git clone http://github.com/d-w-moore/irods-development
       ```
  * 2.The top level directory will include a `Dockerfile` containing:
       ```
       FROM ubuntu:18.04
       RUN apt update
       RUN apt install -y vim git tig sudo python curl wget nano
       WORKDIR /root
       RUN git clone http://github.com/d-w-moore/ubuntu_irods_installer
       RUN ./ubuntu_irods_installer/install.sh --w='config-essentials create-db add-needed-runtime' 0
       RUN ./ubuntu_irods_installer/install.sh -r 4
       ```
  * 3.`cd` to that top level directory and build the container for running iRODS from this `Dockerfile`
    ```
    $ cd ~/github/irods-development ; docker build -t run-irods .
    ```
  * 4.Start the container via:
    ```
    $ docker run --name my_irods -it run-irods
    ```
  * 5.**(In the docker container)** Start the PostgreSQL database server and test it is ready:  
    ```
    $ service postgresql start && sudo su - postgres -c 'psql -c "\l"'
    ```
    This should produce a listing such as the one below; the ICAT database must exist (and be empty) at this point
    to support object cataloguing operations by the iRODS server as it is configured and as it runs.
    ```
    * Starting PostgreSQL 10 database server                                   [ OK ]
                                List of databases
       Name    |  Owner   | Encoding | Collate |  Ctype  |   Access privileges   
    -----------+----------+----------+---------+---------+-----------------------
     ICAT      | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =Tc/postgres         +
               |          |          |         |         | postgres=CTc/postgres+

    (... ICAT's the essential but other DB's will be listed here ...)
    ```
  * 6.**(In the docker container)** Issue the command: `./ubuntu_irods_installer/install.sh   5`

    ```
    Warning: Hostname `05875862c42b` should be a fully qualified domain name.
    Updating /var/lib/irods/VERSION.json...
    The iRODS service account name needs to be defined.
    iRODS user [irods]:
    iRODS group [irods]:

    +--------------------------------+
    | Setting up the service account |
    +--------------------------------+
    
            ...

    +--------------------------------+
    | iRODS is installed and running |
    +--------------------------------+

    == 5 == Y
    ```
    We're now live with an iRODS server instance running inside the docker container.
   
  * 7.Try a manual `iput` and `ils`:
    ```
    root@05875862c42b:~# su - irods
    irods@05875862c42b:~$ ils
    /tempZone/home/rods:
    irods@05875862c42b:~$ iput VERSION.json
    irods@05875862c42b:~$ ils
    /tempZone/home/rods:
      VERSION.json
    ```

  * 8.When ready to leave the container, there are two choices:
    - `exit` or `<Ctrl-D>` to kill the container
       * subsequent restarts of the container will necessitate restarting the DB and irods servers:
       ```
       bash-shell-on-host:~/$ docker start -ia my_irods
       root@05875862c42b:~# service postgresql restart ; service irods restart
       ```
    - `<Ctrl-P> <Ctrl-Q>` to detach from the container

---

## Tips and Tricks

### Password-less sudo

In the above exercise, we run as the root user, but if there is a choice, it will be more convenient and probably safer
to run as a non-root user with "passwordless" sudo access to cover any adminstrative commands required in the container.
This can be achieved using the following command line (assuming nano is your preferred editor):

```
#(sudo) env EDITOR=nano visudo
```

While in the editor, append the following line to the sudoers file (assuming a user called `ubuntu`);
change to reflect your own login name):

```
ubuntu ALL=(ALL) NOPASSWD: ALL
```

### Package Management Commands

It will also help to have some familiarity with the package management commands of the operating system; in
Ubuntu's case that would be the Debian command line utilities `dpkg` (installs/deinstalls .deb files) and
`apt` (the Internet equivalent, which  understands dependencies, networking and package repositories).

In a nutshell,  these are the package commands that will be useful most often (consult the Appendix for a
complete list of Ubuntu  package commands and options):

```
dpkg
         -i PKGFILE     # install from a .DEB pkgfile

         -c PKGFILE     # list component files that would be installed from a .DEB pkgfile

         -l PATTERN\*   # list installed packages with names conforming to PATTERN
                        #   ('ii'  in the first two columns denotes a package properly and completely installed)
                        
         -r PACKAGE     # remove the installed PACKAGE

         -L PACKAGE     # print the list of file paths make up the installed PACKAGE

         -S FULLPATH    # print which installed PACKAGE "owns" the dir/file at FULLPATH


apt-get  install [-y] pkg ...   # install the pkg(s) from the system's configured repos, including  dependencies
apt-get  update                 # refresh the system APT repository information (helpful if install isn't working)
apt-get  remove  pkg ...
apt-cache search pattern.\*     # uses the regex pattern to search configured repositories for matching package names

NOTE: Usually the `apt` command will suffice as an abbreviated stand-in for the `apt-get` command.

```

## Exercises - On to CentOS 7

1A.  Clone another git repository :
      ```
      $ git clone http://github.com/d-w-moore/c7irods
      ```
     The aim will be (again under Docker) to install a single node iRODS server, but this time on a different distribution of Linux: CentOS 7
     Following the instructions in the first part of the README,
  * 1. Build and  runn the Docker container
  * 2. Verify you can interact with the iRODS server functions once inside the container.

1B.  Extra Credit. This exercise shows more detail in terms of what is necessary to build and install within one Dockerfile.
  * 1. Following the instructions in the second part of the `c7irods` repository README , build a new Docker container
  * 2. Examine the `Dockerfile.in-build-install`.   It directly implements the stages of a from-scratch iRODS installation per 
        [directions](https://docs.irods.org/4.2.8/getting_started/installation/) given by the iRODS website , including adding the package repository  and creating the ICAT database and iRODS database user.
  * 3. Within the same directory this Dockerfile is a sample run of the just-built container, in `session.md`. Echo the commands given 
       in that sample session, and observe the console messages
       printed on your display.  Note that during the build, iRODS was installed under a different Docker layer from the one
       presently running, thus we had to force the hostname for the running container to be the same as the one stored  by the build process in '/tmp/hostname' ! This peculiar liability of the Docker build process is one disadvantage of an all-in-one install -- and the main reason why , in this tutorial guide, we will mostly adhere to a strategy of
       installing iRODS during the container run phase rather than the build phase.
