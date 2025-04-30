#!/bin/bash
#SBATCH --job-name=batch_job

# sbatch --ntasks=2 server.slurm
# sbatch --job-name=node_2_bench benchmark.slurm

# sbatch --ntasks=4 server.slurm
# sbatch --job-name=node_4_bench benchmark.slurm

# sbatch --ntasks=8 server.slurm
# sbatch --job-name=node_8_bench benchmark.slurm

# sbatch --ntasks=16 server.slurm
# sbatch --job-name=node_16_bench benchmark.slurm

# sbatch --ntasks=22 server.slurm
# sbatch --job-name=node_22_bench benchmark.slurm

# sbatch --ntasks=28 server.slurm
# sbatch --job-name=node_28_bench benchmark.slurm

# sbatch --ntasks=32 server.slurm
# sbatch --job-name=node_32_bench benchmark.slurm

# sbatch --ntasks=36 server.slurm
# sbatch --job-name=node_36_bench benchmark.slurm

# sbatch --ntasks=42 server.slurm
# sbatch --job-name=node_42_bench benchmark.slurm

sbatch --ntasks=52 server.slurm
sbatch --job-name=node_52_bench benchmark.slurm

# sbatch --ntasks=62 server.slurm
# sbatch --job-name=node_62_bench benchmark.slurm

