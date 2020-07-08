
# Installing iRODS in a Docker container

   1. Set up `git` and `docker`

   On a Linux workstation or VM (Ubuntu, SuSE, and RHEL / CentOS 7 are good choices) make sure you are working as a user with access to all administrative commands via `sudo`, without needing to enter a password.

   The passwordless access is achieved by editing the `/etc/sudoers` file (`visudo` is the tool of choice on most Linux distributions) and appending the line:

   ```
   [username] ALL=(ALL) NOPASSWD: ALL
   ```
   and in so doing, replacing `[username]` with your login name.

   1. In a directory `~/github` create a local copy of this repo.
   ```
   $ git clone http://github.com/d-w-moore/irods-development
   ```


   ```
   FROM ubuntu:18.04
   RUN apt update
   RUN apt install -y vim git tig sudo python curl wget
   WORKDIR /root
   RUN git clone http://github.com/d-w-moore/ubuntu_irods_installer
   RUN ./ubuntu_irods_installer/install.sh --w='config-essentials create-db add-needed-runtime' 0
   RUN ./ubuntu_irods_installer/install.sh -r 4
   ```

  1. type:`service postgresql start && sudo su - postgres -c 'psql -c "\l"'`

  ```
  * Starting PostgreSQL 10 database server                                   [ OK ]
                              List of databases
   Name    |  Owner   | Encoding | Collate |  Ctype  |   Access privileges   
-----------+----------+----------+---------+---------+-----------------------
 ICAT      | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =Tc/postgres         +
           |          |          |         |         | postgres=CTc/postgres+

  ```
  1. Issue the command: `./ubuntu_irods_installer/install.sh   5`

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
root@05875862c42b:~# su - irods
irods@05875862c42b:~$ ils
/tempZone/home/rods:
irods@05875862c42b:~$ iput VERSION.json
irods@05875862c42b:~$ ils
/tempZone/home/rods:
  VERSION.json
  ```
# irods-development
