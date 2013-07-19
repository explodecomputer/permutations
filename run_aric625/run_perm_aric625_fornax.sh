#!/bin/bash

#PBS -W group_list=director553
#PBS -q workq
#PBS -l select=1:ncpus=12:ngpus=1:mem=4000mb
#PBS -l place=excl
#PBS -N aric625
#PBS -J 621-1000
#PBS -l walltime=04:00:00
#PBS -o job_reports/
#PBS -e job_reports/

set -e

if [ -n "${1}" ]; then
  PBS_ARRAY_INDEX=${1}
fi
id=${PBS_ARRAY_INDEX}

rtdir="/home/ghemani/repo/permutations/"
epiGPU="${rtdir}scripts/epiGPU"
data="${rtdir}data/aric625.egu"
phen="${rtdir}data/phen_aric625.txt"
output="${rtdir}results/res_aric625_${id}.txt"

cd /home/ghemani/repo/permutations/run_aric625

if [ -f results/res_aric625_${id}.RData ]; then
  exit
fi

${epiGPU} -A ${data} ${output} -p ${id} -i 2048 -t i -F 8 -I 13 -P ${phen}

gzip -f ${output}
