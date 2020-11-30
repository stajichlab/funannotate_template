#!/usr/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=16 --mem 16gb
#SBATCH --output=logs/annotfunc.%a.log
#SBATCH --time=2-0:00:00
#SBATCH -p intel -J annotfunc

module unload miniconda2
module unload miniconda3
module unload perl
module unload python
module load funannotate/1.8.2
module load phobius

export FUNANNOTATE_DB=/bigdata/stajichlab/shared/lib/funannotate_db
CPUS=$SLURM_CPUS_ON_NODE
OUTDIR=annotate
INDIR=genomes
SAMPFILE=samples.csv
BUSCO=fungi_odb10

if [ -z $CPUS ]; then
  CPUS=1
fi

N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
  N=$1
  if [ -z $N ]; then
    echo "need to provide a number by --array or cmdline"
    exit
  fi
fi
MAX=`wc -l $SAMPFILE | awk '{print $1}'`

if [ $N -gt $MAX ]; then
  echo "$N is too big, only $MAX lines in $SAMPFILE"
  exit
fi
IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read SPECIES STRAIN PHYLUM BIOSAMPLE BIOPROJECT LOCUSTAG
do
  BASE=$(echo -n "$SPECIES $STRAIN" | perl -p -e 's/\s+/_/g')
  STRAIN_NOSPACE=$(echo -n "$STRAIN" | perl -p -e 's/\s+/_/g')
  echo "$BASE"
  MASKED=$(realpath $INDIR/$BASE.masked.fasta)
  if [ ! -f $MASKED ]; then
    echo "Cannot find $BASE.masked.fasta in $INDIR - may not have been run yet"
    exit
  fi
  TEMPLATE=$(realpath lib/sbt/$STRAIN_NOSPACE.sbt)
  if [ ! -f $TEMPLATE ]; then
    echo "NO TEMPLATE for $name"
    exit
  fi
  ANTISMASHRESULT=$OUTDIR/$name/annotate_misc/antiSMASH.results.gbk
  echo "$name $species"
  if [[ ! -f $ANTISMASHRESULT && -d $OUTDIR/$name/antismash_local ]]; then
    ANTISMASH=$OUTDIR/$name/antismash_local/${SPECIES}_$name.gbk
    if [ ! -f $ANTISMASH ]; then
      echo "CANNOT FIND $ANTISMASH in $OUTDIR/$name/antismash_local"
    else
      rsync -a $ANTISMASH $ANTISMASHRESULT
    fi
  fi
  # need to add detect for antismash and then add that
  funannotate annotate --sbt $TEMPLATE --busco_db $BUSCO -i $OUTDIR/$BASE --species "$SPECIES" --strain "$STRAIN" --cpus $CPUS $MOREFEATURE $EXTRAANNOT
done
