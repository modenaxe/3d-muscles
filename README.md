# Overview


## Contents
This repository includes:

1. Anatomical dataset LHDL
2. OpenSim model with `straight-lines muscles` built from the LHDL dataset using NMSBuilder
3. OpenSim model with `highly discretized muscles`
4. scripts and data to reproduce the results of the published paper.

## Requirements
In order to take full advantage of the content of this repository you will need to:
1. [OpenSim 3.3](https://simtk.org/projects/opensim). To download it go to the `Download` page and click on `Previous releases`. 
![how_to_get_OS3.3](https://github.com/modenaxe/3d-muscles/blob/master/images/get_osim3.3.PNG)
2. set up the OpenSim 3.3 API. Please refer to the OpenSim [documentation](https://simtk-confluence.stanford.edu/display/OpenSim/Scripting+with+Matlab).
3. have MATLAB installed in your machine. The analysis of the paper were done using version R2017b.
4. (optional) [NMSBuilder](http://www.nmsbuilder.org)


## Visualise the anatomical dataset 
The LHDL anatomical dataset employed in this study is available in the folder [_LHDL_hip_r_dataset](https://github.com/modenaxe/3d-muscles/tree/master/_LHDL_hip_r_dataset) 
and can be visualised and used to build an OpenSim model using [NMSBuilder](http://www.nmsbuilder.org).

Please refer to the NMSBuilder [website](http://www.nmsbuilder.org) for documentation on how to use that software.

# How to use the MATLAB scripts available in this folder
These scripts allow the reviewers of the manuscript Modenese L and Kohout J (2019). “Automated Generation of Three-Dimensional Complex Muscle Geometries for Use in Personalised Musculoskeletal Models.” submitted to Annals of Biomedical Engineering to visualise the musculoskeletal models generated in the reported analyses and recreate the two main figures included in the manuscript (Figure 4 and Figure 5), presenting the results for the moment arms.

## REQUIREMENTS 
* the OpenSim (v3.3) API for MATLAB have to be installed before using these scripts. All models and scripts are designed to be used in OpenSim 3.3, although it is possible to import the highly discretized models also in OpenSim 4.0 for better visualization, as OpenSim v4 allows using different colours for the fibres of each muscle.

## USE
The scripts are meant to be executed following the alpha-numerical order, i.e. a, b1, b2, etc.  The folders starting with “_” are support folders containing functions and data used in the main scripts. 
# Limitations

# Future work

## IMPORTANT 
Please note that the results presented in the manuscript were generated from fibre lengths obtained from kinematic simulations performed in LHPBuilder. A version of LHPBuilder compatible with the use done in this paper can be downloaded from [this website](https://mi.kiv.zcu.cz/en/research/musculoskeletal.html), however this is a computational  tool normally requiring preliminary training to be used, so we decided instead to include in this package OpenSim models already implementing the muscle fibre kinematics computed by LHPBuilder. This approach simplifies the reproducibility of the paper results because it allows to calculate the muscle fibre lengths using the OpenSim API directly. Please note that because of rounding errors in generating the models, some decimals of the results might differ from what reported in the manuscript. The LHPBuilder models and files are available on request.
