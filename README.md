# Object-Based Attention and Gender Differences in an ASD Cohort

## Overview

This repository contains an Open Science commentary and statistical re-analysis investigating biological sex differences in object-based face processing speed within an Autism Spectrum Disorder (ASD) cohort. 

The primary focus of this project is end-to-end reproducibility as a core technical standard.

## Repository Structure
To separate computational workflows from long-term heavy data storage, this project is split across two platforms:

- GitHub (Code, Logs, and Reports): [GitHub Repository](https://github.com/giorgialepschy/object-based-attention-gender)
- OSF Storage (Data & Preregistration): [OSF Project](https://osf.io/s6rgu/overview)

## Usage instructions

To replicate the analysis, please use RStudio, open the file “commentary_analysis_code.R” and execute the code. Importing the dataset file manually will not be necessary as the code automatically retrieves it from OSF (this will require an internet connection).

In order for the scripts to run smoothly, the R packages “osfr” and “lme4” need to be installed; if they are not already, the code automatically prompts the installation procedure. Please note that the analysis was run on R version 4.2.3, so replicating it on a different version may result in incompatibility issues.

## Source

The original dataset was collected by Eloisa Valenza and Giulia Calignano.

- Original study reference: [OSF Original Study](https://osf.io/jqz3p/overview)
- Data integrity: The raw data file has not been altered or tampered with in any way. Any preprocessing steps are fully transparent and scripted within our pipeline.


## License

This project is licensed under:

Creative Commons Attribution 4.0 International (CC BY 4.0)

You are free to share and adapt this material as long as appropriate credit is given. See the LICENSE file for full terms.

## Authors

- Alberto Briolotta
- Andrea Serrecchia
- Aurora Valtulina
- Giorgia Lepschy
- Matteo Bizzotto

University of Padua
