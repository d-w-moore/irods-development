# Beginning

---

## Setting up

  * 1. Login as an administrative user on a Windows, Mac, or Linux workstation (or VM).

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
   
  * 1. In a directory `~/github` create a local copy of this repo.
       ```
       $ mkdir ~/github ; cd ~/github ; git clone http://github.com/d-w-moore/irods-development
       ```
  * 2. The top level directory will include a `Dockerfile` containing:
       ```
       FROM ubuntu:18.04
       RUN apt update
       RUN apt install -y vim git tig sudo python curl wget
       WORKDIR /root
       RUN git clone http://github.com/d-w-moore/ubuntu_irods_installer
       RUN ./ubuntu_irods_installer/install.sh --w='config-essentials create-db add-needed-runtime' 0
       RUN ./ubuntu_irods_installer/install.sh -r 4
       ```
  * 3. `cd` to that top level directory and build the container for running iRODS from this `Dockerfile`
    ```
    $ cd ~/github/irods-development ; docker build -t run-irods .
    ```
  * 4. Start the container via:
    ```
    $ docker run --name my_irods -it run-irods
    ```
  * 5. **(In the docker container)** Test the database is ready: `service postgresql start && sudo su - postgres -c 'psql -c "\l"'`
    ```
    * Starting PostgreSQL 10 database server                                   [ OK ]
                                List of databases
       Name    |  Owner   | Encoding | Collate |  Ctype  |   Access privileges   
    -----------+----------+----------+---------+---------+-----------------------
     ICAT      | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =Tc/postgres         +
               |          |          |         |         | postgres=CTc/postgres+

    (... ICAT's the essential but other DB's will be listed here ...)
    ```
  * 6. **(In the docker container)** Issue the command: `./ubuntu_irods_installer/install.sh   5`

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
   
  * 7. Try a manual `iput` and `ils`:
    ```
    root@05875862c42b:~# su - irods
    irods@05875862c42b:~$ ils
    /tempZone/home/rods:
    irods@05875862c42b:~$ iput VERSION.json
    irods@05875862c42b:~$ ils
    /tempZone/home/rods:
      VERSION.json
    ```

  * 8. When ready to leave the container, there are two choices:
    - `exit` or `<Ctrl-D>` to kill the container
       * subsequent restarts of the container will necessitate restarting the DB and irods servers:
       ```
       bash-shell-on-host:~/$ docker start -ia my_irods
       root@05875862c42b:~# service postgresql restart ; service irods restart        
       ```
    - `<Ctrl-P> <Ctrl-Q>` to detach from the container

