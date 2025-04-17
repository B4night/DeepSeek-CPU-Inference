#!/bin/bash
#SBATCH --job-name=rpc_server
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=workq
#SBATCH --ntasks=2  # Increase this to add more RPC servers 
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=192
#SBATCH --hint=nomultithread
#SBATCH --time=1:30:00

source activate download_r1
BASEDIR=/scratch/feic/pjs/DeepSeek-CPU-Inference/slurm
INSTALLDIR=${BASEDIR}/llama_cpp_install
export PATH=${INSTALLDIR}/bin:$PATH
export LD_LIBRARY_PATH=${INSTALLDIR}/lib64:$LD_LIBRARY_PATH

export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
# Getting the node names
nodes=$(scontrol show hostnames "$SLURM_JOB_NODELIST")
nodes_array=($nodes)
echo "Node IDs of participating nodes ${nodes_array[*]}"

# Get the IP address and set port for SERVER 
head_node="${nodes_array[0]}"
echo "Writing all IP addresses to server_info and starting the rpc_server on each of participating node"
rm -f server_info
for (( i=0; i< ${SLURM_NNODES}; i++ ))
do 
  server_ip=$(srun -n 1 -N 1  -w ${nodes_array[i]} /bin/hostname -I | cut -d " " -f 2)
  server_port=$(srun -n 1 -N 1  -w ${nodes_array[i]} python3 -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
  echo "${server_ip}:${server_port}" >> server_info
  srun -n 1 -N 1 -c ${SLURM_CPUS_PER_TASK} -w ${nodes_array[i]} --cpu-bind=cores \
  bash -c "python3 worker_diagnostics.py --role server & rpc-server -H ${server_ip} -p ${server_port}" &
done
wait
