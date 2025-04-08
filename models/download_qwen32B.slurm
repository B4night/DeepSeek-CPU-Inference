#!/bin/bash --login
#SBATCH --job-name=download_r1
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=64
#SBATCH --partition=ppn

source activate download_r1

# 启用 git-lfs（需要一次性初始化）
git lfs install

# Clone 模型仓库
git clone https://huggingface.co/Qwen/QwQ-32B-GGUF
cd QwQ-32B-GGUF

# 下载真正的模型权重（重点）
git lfs pull

