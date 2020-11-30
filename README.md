# funannotate_template
Project template for doing a funannotate annotation set.

To use this do not clone it directly, but instead use the 'use this template' to create your own repository from this repo.

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

On the UCR HPCC [here are directions](https://github.com/ucr-hpcc/hpcc_slurm_examples/tree/master/singularity/mariadb) on how to setup your own mysql instance in your account using [singularity](https://sylabs.io/docs/). If you were running funannotate on your own linux/mac setup you would just do a native mysql/mariadb install and have the server running on your local machine. 

The HPCC instructions include the steps to initialize a database followed by you will start a job that will be running which has the mysql instance. This db server will need to be started before you start annotating and be shutdown when you are finished. I often give it a long life like 2 weeks but it can be stopped at any point too.

## Run Training

sbatch 02_train_RNASeq.sh

# Gene Prediction

## Input needs

Informant proteins and transcripts. Funannotate will use the uniprot_swissprot database by default (installed in `$FUNANNOTATE_DB`).

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

# Optional - update

If you have RNAseq you can do an update. For this workflow this would be already aligned reads and PASA database created in the training step. So the input to this is only the previously run training data and the input folder for annotation.

If you are doing an update on an already annotated genome obtained from genbank you will want to provide forward and reverse reads (`--left` and `--right`).

# Functional annotation

```bash
sbatch -a 1-3 06_annotate_function.sh
```
