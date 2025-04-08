#!/bin/bash --login
#SBATCH --job-name=download_fp16
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=32
#SBATCH --partition=ppn
source activate download_r1

# 下载整个 FP16 文件夹（只下载你要的部分）
huggingface-cli download \
  unsloth/DeepSeek-R1-Distill-Llama-70B-GGUF \
  --local-dir ./DeepSeek-FP16 \
  --local-dir-use-symlinks False \
  --repo-type model \
  --resume-download \
  --include "DeepSeek-R1-Distill-Llama-70B-F16*"
