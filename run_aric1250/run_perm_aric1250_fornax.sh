#!/bin/bash

#PBS -W group_list=director553
#PBS -q workq
#PBS -l select=1:ncpus=12:ngpus=1:mem=4000mb
#PBS -l place=excl
#PBS -N aric1250
#PBS -J 1-1000
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
data="${rtdir}data/aric1250.egu"
phen="${rtdir}data/phen_aric1250.txt"
output="${rtdir}results/res_aric1250_${id}.txt"

cd /home/ghemani/repo/permutations/run_aric1250

if [ -f results/res_aric1250_${id}.RData ]; then
  exit
fi

${epiGPU} -A ${data} ${output} -p ${id} -i 2048 -t i -F 8 -I 13 -P ${phen}

gzip -f ${output}
