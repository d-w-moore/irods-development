
# Installing iRODS in a Docker container

   1. Set up on a Linux workstation or VM ( Debian, Ubuntu, SuSE, and RHEL / CentOS 7 are good choices) with a  user account has access to all administrative commands via `sudo`
       - Best to configure sudo without needing to enter a password.
       - The passwordless access is achieved by editing the `/etc/sudoers` file (`visudo` is the tool of choice on most Linux distributions) and appending the line (       replacing `[username]` with your login name):
       ```
       [username] ALL=(ALL) NOPASSWD: ALL
       ```
       [forcing nano](#forcing_nano)

       - Set up the tools you'll need throughout this development quide.
       ```
       sudo apt update && sudo apt install git docker.io
       ```
       - You'll then need to adjust permissions for your login user to use `docker`:
       ```
       sudo usermod -aG docker [username]
       ```
       and then log out and back in again. Reboot if this is insufficient. You'll know docker is properly configured when you can run the following
       command without error :
       ```
       $ docker ps
       ```
   2. In a directory `~/github` create a local copy of this repo.
   ```
   $ mkdir ~/github ; cd ~/github ; git clone http://github.com/d-w-moore/irods-development
   ```
   3. The top level directory will include a `Dockerfile` containing:
```
FROM ubuntu:18.04
RUN apt update
RUN apt install -y vim git tig sudo python curl wget
WORKDIR /root
RUN git clone http://github.com/d-w-moore/ubuntu_irods_installer
RUN ./ubuntu_irods_installer/install.sh --w='config-essentials create-db add-needed-runtime' 0
RUN ./ubuntu_irods_installer/install.sh -r 4
```
   4. `cd` to that top level directory and build the container for running iRODS from this `Dockerfile`
   ```
   $ cd ~/github/irods-development ; docker build -t run-irods .
   ```
   5. Start the container via:
   ```
   $ docker run --name my_irods -it run-irods
   ```
   6. **(In the docker container)** Test the database is ready: `service postgresql start && sudo su - postgres -c 'psql -c "\l"'`
```
* Starting PostgreSQL 10 database server                                   [ OK ]
                            List of databases
   Name    |  Owner   | Encoding | Collate |  Ctype  |   Access privileges   
-----------+----------+----------+---------+---------+-----------------------
 ICAT      | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =Tc/postgres         +
           |          |          |         |         | postgres=CTc/postgres+

(... ICAT's the essential but other DB's will be listed here ...)
```
  7. **(In the docker container)** Issue the command: `./ubuntu_irods_installer/install.sh   5`

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
   This is the indication that an iRODS server is running live in the container.
   
   7.Try a manual `iput` and `ils`:
```
root@05875862c42b:~# su - irods
irods@05875862c42b:~$ ils
/tempZone/home/rods:
irods@05875862c42b:~$ iput VERSION.json
irods@05875862c42b:~$ ils
/tempZone/home/rods:
  VERSION.json
```

   8. When ready to leave the container, there are two choices:
      1. `exit` or `<Ctrl-D>` to kill the container
        * subsequent restarts of the container will necessitate restarting the DB and irods servers:
        ```
        bash-shell-on-host:~/$ docker start -ia my_irods
        root@05875862c42b:~# service postgresql restart ; service irods restart        
        ```
      1. `<Ctrl-P> <Ctrl-Q>` to detach from the container


---
## Footnotes
  * <A id="forcing_nano">*forcing nano:*</A> : Below is  a possible invocation of visudo if you have a favorite editor already installed, eg. suppose you or the administrator has installed `nano` for convenience (`sudo apt update; sudo apt install nano`):

```
$ EDITOR=nano sudo --preserve-env=EDITOR visudo
```
