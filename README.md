# Overview

This repository contains the data, models and the Matlab scripts to inspect and reproduce the results of the following publication:

```bibtex
@article{Modenese2019three,
  title={Automated Generation of Three-Dimensional Complex Muscle Geometries for Use in Personalised Musculoskeletal Models},
  author={Modenese, Luca and Kohout, Josef},
  journal={Annals of biomedical engineering},
  volume={under review},
  number={under review},
  pages={xx--xx},
  year={2020},
  publisher={Springer}
}
```
Please cite the manuscript if you make use of these materials for your research or presentations.

## Brief summary of the publication
In our manuscript: 
* We used a publicly available anatomical model to create a subject-specific model of the hip joint using bone and muscle geometries obtained from CT and MRI scans
collected on the LHDL cadaveric specimen. 
* We used this model to propose a new method for representing the geometry of the skeletal muscles surrounding the hip joint and how it changes
when the joint moves.
* We compared the muscle moment arms computed with our new approach against previous studies published in the biomechanical literature, finding remarkable agreement for 
ranges of motion consistent with normal gait. If you need some background reading about muscle moment arms, you can refer to this [classic article by An K.N. et al.](http://e.guigon.free.fr/rsc/article/AnEtAl84a.pdf).

![muscle_deformations](https://github.com/modenaxe/3d-muscles/blob/master/images/muscle_deformations.png)

# Requirements
In order to take full advantage of the content of this repository you will need to:
1. [OpenSim 3.3](https://simtk.org/projects/opensim). Required to visualize the models. 
To download it go to the `Download` page and click on `Previous releases`, as shown in [this screenshot](https://github.com/modenaxe/3d-muscles/blob/master/images/get_osim3.3.PNG).
2. have MATLAB installed in your machine. The analyses of the paper were performed using version R2017b.
3. set up the OpenSim 3.3 API. Required to run the provided scripts. Please refer to the OpenSim [documentation](https://simtk-confluence.stanford.edu/display/OpenSim/Scripting+with+Matlab).
4. (optional) [NMSBuilder](http://www.nmsbuilder.org)

# Contents
This repository includes:
1. LHDL Anatomical dataset (see [reference publication](https://www.jstage.jst.go.jp/article/physiolsci/advpub/0/advpub_0_0810200082/_article/-char/ja/)) including:

		a. bone geometries (pelvis, right femur)
		b. muscle geometries (_iliacus_, _psoas_, _gluteus maximus_, _gluteus medius_)
		c. muscle attachments (as point clouds)
2. OpenSim model with `straight-lines muscles` built from the LHDL dataset using NMSBuilder
3. Motion data in OpenSim format (`.mot` files) to simulate the following hip motions:

		a. hip flexion/extension between -10 and 60 degrees
		b. hip abduction/adduction between -40 and 40 degrees 
		c. hip internal/external rotation between -30 and 30 degrees.
4. OpenSim models with `highly discretized muscles`. There is a model for each of the investigated hip motions.
5. MATLAB scripts to recreate:

		a. Figure 4 and Figure 5 presenting the moment arms of the highly discretized muscles and their validation.
		b. the results that were included in Table 1 and Table 2.
Please note that the directories starting with `_` contain support functions and data used by the main scripts. 

## Visualizing the anatomical dataset 
The LHDL anatomical dataset employed in this study is available in the folder [_LHDL_hip_r_dataset](https://github.com/modenaxe/3d-muscles/tree/master/_LHDL_hip_r_dataset) 
and can be visualised and used to build an OpenSim model using [NMSBuilder](http://www.nmsbuilder.org).
Please refer to the NMSBuilder [website](http://www.nmsbuilder.org) for documentation on how to use that software.
![NMSBuilder_LHDL](https://github.com/modenaxe/3d-muscles/blob/master/images/NMSBuilder_view.png)

## Visualizing the OpenSim models
All models and scripts are designed to be used in OpenSim 3.3, although 
it is possible to import the highly discretized models also in OpenSim 4.0 for better visualization, as OpenSim v4 allows using different colours for the fibres of each muscle.
![OpenSim_models](https://github.com/modenaxe/3d-muscles/blob/master/images/OpenSim3_models.png)

## Running the MATLAB scripts
The provided MATLAB scripts are meant to be executed in sequential order following the alphabetical order of the first character.
For scripts with the same initial character, the second character, which is a number, suggests the order of execution.
So the order is:
1. a_compute_biomech_moving_viapoints.m
2. b1_plot_momArms_Fig4_as_Blemker2005.m
3. b2_plot_momArms_Fig5_as_Blemker2005.m
4. etc.

# Limitations and further notes about reproducibility
* The highly discretized muscle models are meant to be used for simulating the provided hip joint tasks and nothing else.
* Please note that the results for the highly discretized muscles presented in the manuscript were generated from kinematic simulations 
performed in LHPBuilder, a multimodal viewer for biomechanical application that is not developed or supported anymore. 
A version of LHPBuilder compatible with the use done in this paper can be downloaded from 
[this website](https://mi.kiv.zcu.cz/en/research/musculoskeletal.html). LHPBuilder is a complex
 tool requiring preliminary training to be used, so we decided instead to implement the muscle fibre kinematics in the OpenSim models directly. 
 This approach simplifies the reproducibility of our results because it allows to calculate the muscle fibre lengths using the OpenSim API directly. 
 Please note that because of rounding errors in generating the models, some decimals of the results might differ from what reported in the manuscript. 
 The LHPBuilder models and files are available on request.

# Future work
* A prototype of an `OpenSim plugin` implementing the methods described in this manuscript has already been
implemented and a preview is visible on Youtube [at this link](https://www.youtube.com/watch?v=BW_jjCcbf5o). The source code will be released with one of our next publications.
* Upgrade scripts to openSim 4.0.
* link to *work in progress* repository with LHPBuilder files.
