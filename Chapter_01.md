# Beginning

---

## Setting up

  * 1.Login as an administrative user on a Windows, Mac, or Linux workstation (or VM).

       (We'll need it now for installing Docker and git; and after a couple of chapters, for installing other
       software, such as docker-compose and python.)

       The "missing package manager" [brew](https://docs.brew.sh/Installation) may be installed on Mac machines to offer access to many convenient extras, such as 'tig', 'fish', etc.

       For the purposes of the exercise in this first chapter, please install [docker](http://docs.docker.com) and [git](http://git-scm.com) by clicking on the appropriate OS platform links on the respective websites.

       On Ubuntu Linux, you can simply do the following:
       ```
       sudo apt update && sudo apt install git docker.io
       ```
       and will then need to adjust permissions for your login account to have `docker` daemon access:
       ```
       sudo usermod -aG docker [username]
       ```
       Then log out and back in again. (Reboot if this is insufficient.)
       You'll know docker is properly configured when you can run the following
       command without error :
       ```
       $ docker ps
       ```
---

## Configuring and running an iRODS server in Docker

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
  * 5.**(In the docker container)** Test the database is ready: `service postgresql start && sudo su - postgres -c 'psql -c "\l"'`
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
    We're now live with an iRODS server instance runnint inside the docker container.
   
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

### Passwordless sudo

In the above exercise, we run as the root user, using a 'robot' script `install.sh` designed to automate the
process of installing packages whether remote (in a well known repository) or local (downloaded or built by the user).

If there is a choice, it may be convenient to run as a non-root user with "passwordless" sudo access. This can be
achieved using the following command line (assuming nano is your preferred editor):

```
  # (sudo) env EDITOR=nano visudo
```

While in the editor, append the following line to the sudoers file (assuming a sudo-enabled login of `ubuntu`;
change to reflect your own login name):

```
  ubuntu ALL=(ALL) NOPASSWD: ALL
```

It will also help to have some familiarity with the package management commands of the operating system; in
Ubuntu's case that would be the Debian command line utilities `dpkg` (installs/deinstalls .deb files) and
`apt` (the Internet equivalent, which  understands dependencies, networking and package repositories).

In a nutshell,  these are the package commands that will be useful most often (consult the Appendix for a
complete list of Ubuntu  package commands and options):

```
dpkg
         -i PKGFILE     # install from a .DEB pkgfile

         -c PKGFILE     # list component file from a .DEB pkgfile

         -l PATTERN\*   # list installed packages with names conforming to PATTERN

         -r PACKAGE     # remove the installed PACKAGE

         -L PACKAGE     # print the list of file paths make up the installed PACKAGE

         -S FULLPATH    # print which installed PACKAGE "owns" the dir/file at FULLPATH


apt-get  install [-y] pkg ...   # install the pkg(s) from the system's configured repos, including  dependencies
apt-get  update                 # refresh the system APT repository information (helpful if install isn't working)
apt-get  remove  pkg ...
apt-cache search pattern.\*     # uses the regex pattern to search configured repositories for matching package names

NOTE: Usually the `apt` command will suffice as an abbreviated stand-in for the `apt-get` command.

```
