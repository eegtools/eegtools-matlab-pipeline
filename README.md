# matlab-pipeline
Complete EEG analysis (ERP, ERSP, Sources) pipeline written in matlab, using EEGLAB and BRAINSTORM

## Description

EEGTools was developed in the Robotics, Brain and Cognitive Sciences (RBCS) department of the Istituto Italiano di Tecnologia (IIT) of Genova, Italy.
It has been equally developed by Alberto Inuggi and Claudio Campus, Ph.D. Researchers currently working respectively for the RBCS (https://www.iit.it/lines/robotics-brain-and-cognitive-sciences) and U-VIP (https://www.iit.it/lines/unit-for-visually-impaired-people) units.
It is a huge set of matlab scripts allowing a complete analysis of the Electroencephalography (EEG) signal at either the sensor and source levels.
It implement all the analysis steps relying on the EEGLab (https://sccn.ucsd.edu/eeglab) and Brainstorm (http://neuroimage.usc.edu/brainstorm) software primitives.

## Why use it

Every huge analysis pipeline has a learning curve which must be matched with the advantages it provides to the user.
eegtools offer several features (see next paragraph), most of them can be found in many other software packages. Its unicity is the possibility to model all the characteristics of a huge and complex EEG project and perform automatic analysis. All the analysis steps (but for artefact removal) can be performed in batch mode (code, start, go home and find everything processed next morning). Once you create your clean continuous files, you can concatenate all the steps from epoching to group stats, plotting and results export. This is granted by compiling a huge project_structure.m file, where you can define eeg data characteristics, preprocessing params, participants definition, statistical models, electrodes cluster, time window, frequency bands, analysis types and many other features.
Moreover, it eases the integration between EEGLab and Brainstorm and allows calling the latter methods, and many others custom methods, from matlab command line using the same data structure used for ERP/ERSP analysis.

## Features

* Subject level
  * Import raw files (BrainVision, Biosemi, Geodesic)
  * Filtering
  * Referencing
  * Channel transformation
  * Channel interpolation
  * Subsampling
  * Epoching & Baseline correction
  * Triggers manipulation
  * ICA & CUDAICA
  * Merge different montages
  
* Group level
  * EEGLab Study creation, design and compute measure
  * ERP & ERPS Stats (continuous curve, time-windows, Time-Frequency, frequency-bands, topo-plot, peak-analysis, individual align, individual narrow-band.. etc...)
  * Plotting
  * Result export

* Source analysis
  * EEGLab epochs file import
  * Noise and data covariance estimation
  * BEM creation
  * Individual Source calculation (time, time-frequency, scouts)
  * Source dimensionality reduction (time, space)
  * Z-score, Norm, flattening
  * Source results export to SPM8/12
  * Stats (2-samples paired t-test, scouts stats, TF stats)
  * Results export
  
## One-time Installation

* Download and install both EEGLab (https://sccn.ucsd.edu/eeglab/downloadtoolbox.php) and Brainstorm (http://neuroimage.usc.edu/bst/download.php) software. Rename them to eeglab and brainstorm3 respectively.
* GLOBAL_SCRIPT_ROOT : Copy the present repositories everywhere in your file system. 
* PROJECTS_DATA_ROOT : Create a root folder where you will put all the data (eeg raw files, eeglab set/fdt files and your brainstorm database) of your EEG projects.
* PROJECTS_SCRIPTS_ROOT : Create a root folder where you will put all the matlab script of your EEG projects
Add to Matlab path the GLOBAL_SCRIPT_ROOT path. All the other paths will be added by the pipeline scripts.  

## Project setup

* Create the project data folder   :  PROJECTS_DATA_ROOT/PROJ_NAME
* Create the project script folder :  PROJECTS_SCRIPTS_ROOT/PROJ_NAME
* Copy the following three files from GLOBAL_SCRIPT_ROOT/eeg_tools/templates => PROJECTS_SCRIPTS_ROOT/PROJ_NAME
  * template_project_structure.m
  * template_main_eeglab_subject_processing.m
  * template_main_eeglab_group_processing.m
* Rename these files as wish and edit them as later explained
* Create the folder PROJECTS_DATA_ROOT/PROJ_NAME/original_data and copy there all your raw eeg files

## Usage

In order to analyze an EEG project you will need at least 3 files. 
* A Project Structure file: which describe the data characteristic and all the necessary parameters to perform the analysis
* A main_eeglab_subject_processing.m file which allows analyzing each individual subject
* A main_eeglab_group_processig.m file which define the study, the experimental design and allows performing the requested analysis

Two two main files starts asking you to fill in the following information:

* project.paths.projects_data_root    = '/media/data/EEG_projects_data';
* project.paths.projects_scripts_root = '/media/data/EEG_projects_scripts';
* project.paths.global_scripts_root   = '/media/data/EEG/eegtools/matlab-pipeline';
* project.paths.plugins_root          = '/media/data/matlab/toolboxes';

PROJECT DATA 

* project.research_group      = 'MY_DEPARTMENT_GROUP';
* project.research_subgroup   = 'MY_LAB';
* project.name                = 'my_project';
* project.conf_file_name      = 'project_structure'; 

The last params identify the project structure file, a huge (up to 1500 lines) files containing variables definitions.


