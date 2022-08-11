#!/usr/bin/bash -l
#SBATCH -p batch --time 2-0:00:00 --ntasks 8 --nodes 1 --mem 120G --out logs/repeatmodeler_attempt.%a.log

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

INDIR=genomes
OUTDIR=genomes

mkdir -p repeat_library

SAMPFILE=samples.csv
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
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
tail -n +2 $SAMPFILE | sed -n ${N}p | while read SPECIES STRAIN PHYLUM LOCUS
do
  name=$(echo -n ${SPECIES}_${STRAIN} | perl -p -e 's/\s+/_/g')
  echo "$name"
     module unload perl
     module unload python
     module unload miniconda2
     module unload anaconda3
     module load RepeatModeler
     module load ncbi-blast/2.13.0+
     export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)
	#makeblastdb -in $INDIR/$name.sorted.fasta -dbtype nucl -out repeat_library/$name
	BuildDatabase -name repeat_library/$name $INDIR/$name.sorted.fasta
	RepeatModeler -database repeat_library/$name -pa $CPU
	#-LTRStruct
done
