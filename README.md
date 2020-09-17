# funannotate_template
Project template for doing a funannotate annotation set

# Repeat Masking

```bash
sbatch -a 1-2 01_mask_denovo.sh
```

# Optional steps - with RNASeq

If you are utilizing RNASeq for training and improvement of gene models you can take advantage of the extra speed up that running PASA with a mysql server (instead of the default, SQLite).  To do that on HPCC this requires seting up a mysql server using singularity package.

## Setup mysql/mariadb for your account

## Configure mysql/mariadb

You need to create a file `$HOME/pasa.CONFIG.template` this will be customized for your user account. Copy it from the system installed PASA folder.
A current version on the system is located in `/opt/linux/centos/7.x/x86_64/pkgs/PASA/2.3.3/pasa_conf/pasa.CONFIG.template`.
Doing `rsync /opt/linux/centos/7.x/x86_64/pkgs/PASA/2.4.1/pasa_conf/pasa.CONFIG.template ~/`
This can also be done automatically with the latest version of PASA on the system
```bash
module load PASA/2.4.1
FOLDER=$(dirname `which pasa`)
rsync -v $FOLDER/../pasa_conf/pasa.CONFIG.template
```

You will need to edit this file which has this at the top. The MYSLQSERVER part will get updated by the mysql setup step later so leave  it alone.
You will need to fill in the content for `MYSQL_RW_USER` and `MYSQL_RW_PASSWORD` too.

```
# server actively running MySQL
# MYSQLSERVER=server.com
MYSQLSERVER=localhost
# Pass socket connections through Perl DBI syntax e.g. MYSQLSERVER=mysql_socket=/tmp/mysql.sock

# read-write username and password
MYSQL_RW_USER=xxxxxx
MYSQL_RW_PASSWORD=xxxxxx
```
## Run Training

sbatch 02_train_RNASeq.sh

# Gene Prediction

```bash
sbatch -a 1-2 03_predict.sh
```

# Extra Annotation

## AntiSMASH

```bash
sbatch -a 1-2 04a_antismash_local.sh
```
## InterProScan

```bash
sbatch -a 1-3 04b_iprscan.sh
```
