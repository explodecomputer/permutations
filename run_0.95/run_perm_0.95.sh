#!/bin/bash

#PBS -A Desc006
#PBS -l nodes=1:gpus=1
#PBS -l pmem=4000MB
#PBS -N perms95
#PBS -t 1-500
#PBS -l walltime=12:00:00
#PBS -o job_reports/
#PBS -e job_reports/
#PBS -d /home/josephp/Desc006/repo/permutations/run_0.95

set -e

if [ -n "${1}" ]; then
  PBS_ARRAYID=${1}
fi
id=${PBS_ARRAYID}

rtdir="/home/josephp/Desc006/repo/permutations/"
epiGPU="${rtdir}scripts/epiGPU"
data="${rtdir}data/bsgs_1kg_p1v3_maf0.05_info0.95_chr5-15.egu"
phen="${rtdir}data/phen.txt"
output="${rtdir}results/res_0.95_${id}.txt"

${epiGPU} -A ${data} ${output} -p ${id} -i 2048 -t i -F 6.5 -I 10.5 -P ${phen}

gzip -f ${output}
