#!/bin/bash
#SBATCH --job-name=rpc_client
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=workq
#SBATCH --ntasks=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=192
#SBATCH --hint=nomultithread
#SBATCH --time=1:30:00

BASEDIR=/scratch/feic/pjs/DeepSeek-CPU-Inference/slurm
INSTALLDIR=${BASEDIR}/llama_cpp_install
export PATH=${INSTALLDIR}/bin:$PATH
export LD_LIBRARY_PATH=${INSTALLDIR}/lib64:$LD_LIBRARY_PATH

while [ ! -f ./server_info ]; do
    echo "Waiting for server_info to be available..."
    sleep 5
done

num_servers=$(cat ./server_info | wc -l)
i=0
while read -r LINE
do
    server_info=$LINE
    server_ip=$(echo ${server_info} | cut -d ":" -f 1)
    server_port=$(echo ${server_info} | cut -d ":" -f 2)
    server_list=$(echo ${server_list}${server_ip}:${server_port})
    if [ ${num_servers} -gt 0 ]; then
      if [ ${i} -lt $((${num_servers}-1)) ]; then
      server_list=$(echo ${server_list},)
      else 
      server_list=$(echo ${server_list})
      fi
      i=$((i+1))
    fi
done < ./server_info 


sleep 10
python3 worker_diagnostics.py --role client &
time -p srun -l -n ${SLURM_NTASKS} -N ${SLURM_NNODES} -c ${SLURM_CPUS_PER_TASK} \
llama-cli -m  /scratch/feic/pjs/DeepSeek-CPU-Inference/models/DeepSeek-R1.Q8_0.gguf \
-p "The weather was so perfect that I did not want to go back in the house. But I had left a new beef stew on the stove which needed my attention. Please generate in English what happend next " \
--repeat-penalty 1.0 -n 128 \
--rpc ${server_list} -t 192  -no-cnv -ngl 99
