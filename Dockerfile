# Base image with Mambaforge and Snakemake
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install tools and Mambaforge
RUN apt-get update && apt-get install -y wget bzip2 git && \
    wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh -O /tmp/mambaforge.sh && \
    bash /tmp/mambaforge.sh -b -p /opt/mambaforge && \
    rm /tmp/mambaforge.sh

ENV PATH="/opt/mambaforge/bin:$PATH"

# Install dependencies directly into base environment
RUN mamba install -n base -c conda-forge -c bioconda \
    azure-storage-blob=12.24.0 \
    bcftools=1.20 \
    matplotlib=3.9.1 \
    openjdk=8.0.412 \
    plink=1.90b6.21 \
    pyopenssl=24.2.1 \
    pysam=0.22.1 \
    python=3.10 \
    r-base=4.4.1 \
    r-essentials=4.4 \
    r-qqman=0.1.9 \
    snakemake=7.30.1 && \
    mamba clean --all -y
