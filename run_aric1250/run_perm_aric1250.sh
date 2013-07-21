#!/bin/bash

#PBS -A Desc006
#PBS -l nodes=1:gpus=1
#PBS -N aric1250
#PBS -t 501-1000
#PBS -l walltime=06:00:00
#PBS -o job_reports/
#PBS -e job_reports/
#PBS -d /home/josephp/Desc006/repo/permutations/run_aric1250
#PBS -M g.hemani@uq.edu.au

set -e

if [ -n "${1}" ]; then
  PBS_ARRAYID=${1}
fi
id=${PBS_ARRAYID}

rtdir="/home/josephp/Desc006/repo/permutations/"
epiGPU="${rtdir}scripts/epiGPU"
data="${rtdir}data/aric1250.egu"
phen="${rtdir}data/phen_aric1250.txt"
output="${rtdir}results/res_aric1250_${id}.txt"

${epiGPU} -A ${data} ${output} -p ${id} -i 2048 -t i -F 8 -I 13 -P ${phen}

gzip -f ${output}
