# azure-test

## Introduction

This repository contains a Snakemake pipeline adapted from https://github.com/xin-huang/Lithuanian-archaic-introgression. The pipeline is designed to test the deployment of Snakemake workflows in the cloud. It has been tested on Oracle Linux 9 using the Life Science Compute Cluster at the University of Vienna.


## Usage

1. Install prerequisites: `azure-cli` and `mamba`.

2. Clone this repository:

```
git clone https://github.com/xin-huang/azure-test
cd azure-test
```

3. Create the environment:

```
mamba env create -f workflow/envs/env.yaml
```

4. Activate the environment:

```
mamba activate azure-test
```

5. Log in to Azure account using `azure-cli`:

```
az login --tenant <name>
```

6. Run the pipeline:

```
bash run.sh
```

## Acknowledgement

Xin Huang acknowledges the "Funding for Research with Azure Services" provided by the Vienna University Computer Center at the University of Vienna for supporting this project.
