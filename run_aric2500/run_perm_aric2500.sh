#!/bin/bash

#PBS -A Desc006
#PBS -l nodes=1:gpus=1
#PBS -l pmem=4000MB
#PBS -N aric2500
#PBS -t 1-250
#PBS -l walltime=12:00:00
#PBS -o job_reports/
#PBS -e job_reports/
#PBS -d /home/josephp/Desc006/repo/permutations/run_aric2500

set -e

if [ -n "${1}" ]; then
  PBS_ARRAYID=${1}
fi
id=${PBS_ARRAYID}

rtdir="/home/josephp/Desc006/repo/permutations/"
epiGPU="${rtdir}scripts/epiGPU"
data="${rtdir}data/aric2500.egu"
phen="${rtdir}data/phen_aric2500.txt"
output="${rtdir}results/res_aric2500_${id}.txt"

${epiGPU} -A ${data} ${output} -p ${id} -i 2048 -t i -F 8 -I 13 -P ${phen}

gzip -f ${output}
