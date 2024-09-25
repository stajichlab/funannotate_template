#!/usr/bin/bash -l
#SBATCH --time 2-0:00:00 -N 1 -n 1 -c 16 --mem 64gb --out logs/repeatmodeler.%a.log

module load RepeatModeler
CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

INDIR=genomes
MASKDIR=analysis/RepeatMasker
SAMPLES=samples.csv
RMLIBFOLDER=lib/repeat_library
FUNGILIB=lib/fungi_repeat.20170127.lib.gz
mkdir -p $RMLIBFOLDER
RMLIBFOLDER=$(realpath $RMLIBFOLDER)

OUTDIR=genomes

mkdir -p repeat_library

SAMPFILE=samples.csv
N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
MAX=$(wc -l $SAMPFILE | awk '{print $1}')
if [ $N -gt $(expr $MAX) ]; then
    MAXSMALL=$(expr $MAX)
    echo "$N is too big, only $MAXSMALL lines in $SAMPFILE"
    exit
fi

IFS=,
# this may change depending on your samples file configuration
tail -n +2 $SAMPFILE | sed -n ${N}p | while read SPECIES STRAIN PHYLUM LOCUS RNASEQ
do  
  SPECIESNOSPACE=$(echo -n "$SPECIES $STRAIN" | perl -p -e 's/\s+/_/g')
  LIBRARY=$RMLIBFOLDER/$SPECIESNOSPACE.repeatmodeler.lib
  COMBOLIB=$RMLIBFOLDER/$SPECIESNOSPACE.combined.lib
  
  if [ ! -s $LIBRARY ]; then
  	pushd $MASKDIR/$SPECIESNOSPACE
	BuildDatabase -name $SPECIESNOSPACE $GENOME
	RepeatModeler -threads $CPU -database $SPECIESNOSPACE -LTRStruct
	rsync -a RM_*/consensi.fa.classified $LIBRARY
	rsync -a RM_*/families-classified.stk $RMLIBFOLDER/$SPECIESNOSPACE.repeatmodeler.stk
 	pigz $RMLIBFOLDER/$SPECIESNOSPACE.repeatmodeler.stk
	popd
  fi
  if [ ! -s $COMBOLIB ]; then
  	rsync -a $LIBRARY $COMBOLIB
	zcat $FUNGILIB >> $COMBOLIB
  fi
done
