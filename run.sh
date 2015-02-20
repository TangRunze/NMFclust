# 
#$ -cwd 
#$ -j y 
#$ -pe orte 12
#$ -S /bin/bash 
#
# Name the job #$ -N matlabScript #
matlab -nosplash -nodisplay -r "main; quit;"
echo "" 
echo "Done at " `date` 