#!/bin/bash
#
# Set shell, otherwise the default shell would be used
#$ -S /bin/bash
#
# Make sure that the .e and .o file arrive in the
# working directory
#$ -cwd
#
#Merge the standard out and standard error to one file
#$ -j y
#
#   Send mail on job's end and abort
#$ -M thanujaa@student.ethz.ch 
#$ -m bea
#
source /home/sgeadmin/ITETCELL/common/settings.sh
/bin/echo Running on host: `hostname`
/bin/echo In directory: `pwd`
/bin/echo Starting on: `date`
/bin/echo PATH: `echo $PATH`
/bin/echo TMP: `env | grep TMP` 
#/bin/echo SGE: `env | grep SGE`
/bin/echo MCR: `env | grep MCR`
#
#if [ ! -d "job_storage" ]; then
#  mkdir job_storage 
#fi
#
# Gurobi license
GRB_LICENSE_FILE=/usr/sepp/var-svn/licenses/gurobi/gurobi.lic ;
export GRB_LICENSE_FILE ;
echo GRB_LICENSE_FILE is ${GRB_LICENSE_FILE};

# binary to execute
# /usr/sepp/bin/matlab -nodisplay -r parfor_sge 
/usr/sepp/bin/matlab -nodisplay -r batchRun_cremi_A  
# /home/thanujaa/projects/setA/run_batchRun_cremi_A.sh /usr/pack/matlab-8.5r2015a-fg
echo finished at: `date`
exit 0;
