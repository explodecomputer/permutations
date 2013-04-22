#!/bin/bash

#PBS -W group_list=director553
#PBS -q workq
#PBS -l select=1:ncpus=12:ngpus=1:mem=4000mb
#PBS -l place=excl
#PBS -N unrel95
#PBS -t 251-500
#PBS -l walltime=12:00:00
#PBS -o job_reports/
#PBS -e job_reports/

set -e

if [ -n "${1}" ]; then
  PBS_ARRAY_INDEX=${1}
fi
id=${PBS_ARRAY_INDEX}

rtdir="/home/ghemani/repo/permutations/"
epiGPU="${rtdir}scripts/epiGPU"
data="${rtdir}data/bsgs_1kg_p1v3_maf0.05_info0.95_chr5-15_unrel.egu"
phen="${rtdir}data/phen_unrel.txt"
output="${rtdir}results/res_0.95_unrel_${id}.txt"

${epiGPU} -A ${data} ${output} -p ${id} -i 2048 -t i -F 6.5 -I 10.5 -P ${phen}

gzip -f ${output}
