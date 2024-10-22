# dna-seqfish-plus-tissue
This repostory contains the scripts used in processing the images and barcode calling for the DNA seqFISH+ analysis and probe sequences used in the study.
Last updated on September 13, 2021

## Getting Started
* Download all the contents of the folder and add it to your Matlab path.

### Prerequisites
* MATLAB R2019a

### Dependencies
1. radialcenter.m by Dr. Parthasarathy, which can be downloaded [here](https://pages.uoregon.edu/raghu/particle_tracking.html).
2. Fiji
	* download at:
	* add the scripts folder to the path
```Matlab
addpath('path\Fiji.app\scripts', '-end');
```
3. bfmatlab
	* download at: https://downloads.openmicroscopy.org/bio-formats/5.3.4/artifacts/bfmatlab.zip
	* add to MATLAB path
	* add "bioformats_package.jar" to javapath
```Matlab
javaaddpath('path\bioformats_package.jar');
```

## Running the Code
*Overview of the steps for the DNA seqFISH pipeline*
### Prerequisites
* Region of interests (ROI) holds polygon cell segmentations created from ImageJ software
* thresholding values after Preprocessing Step

## packages
example scripts can be found in each package
| package  | Description |
| ------------- | ------------- |
| align  | dapi alignment  |
| io  | TIFF readers and save wrappers  |
| immunofluorescence  | retrieve intensity profile of images  |
| beads | detect beads |
| beadalignment | python package for bead alignment |
| threshold  | manual and auto  |
| preprocess | preprocessing filters |
| process  | grab spots and organize  |
| decode  | decode genes  |
| segment | io for ilastik masks, assign points to masks  |
| sequential | sequential experiment functions |
| misc  | extra scripts used for sequential thresholding and spot finding |

## License
Free for non-commercial and academic research. The software is bound by the licensing rules of California Institute of Technology (Caltech)

## Image Processing Team
* Yodai Takei - writing, cleaning, debugging, and validating code
* Nico Pierson - writing, cleaning, debugging, and validating code
* Sheel Shah - decoding, spot finding, and 3D nuclear segmentation
* Jonathan White - fiduciary alignment


## Contact
* Contact the corresponding author: Long Cai (lcai@caltech.edu) for any inquiry.


