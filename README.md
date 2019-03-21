# QMRITools

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2530801.svg)](https://doi.org/10.5281/zenodo.2530801)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues)
[![HitCount](http://hits.dwyl.io/mfroeling/DTITools.svg)](http://hits.dwyl.io/mfroeling/DTITools)
[![status](http://joss.theoj.org/papers/ef8bfb6c31499845d353b6a5af0d6300/status.svg)](http://joss.theoj.org/papers/ef8bfb6c31499845d353b6a5af0d6300)

## Contents

* [Information](#information)
* [Documentation](#documentation)
* [Install toolbox](#install-toolbox)
* [Demonstrations](#demonstrations)
* [Using the toolbox](#using-the-toolbox)
* [Functionality](#functionality)

## Information

QMRITools is developed for [Mathematica](https://www.wolfram.com/mathematica/).
It contains the following toolboxes:

- CardiacTools
- CoilTools
- DenoiseTools
- DixonTools
- ElastixTools
- GeneralTools
- GradientTools
- ImportTools
- IVIMTools
- JcouplingTools
- MaskingTools
- NiftiTools
- PhysiologyTools
- PlottingTools
- ProcessingTools
- RelaxometryTools
- SimulationTools
- VisteTools

## Documentation

Documentation of all functions and their options is fully integrated in the Mathematica documentation. The toolbox always works within the latest version of Mathematica and does not support any backward compatibility.
After the toolbox is installed correctly it should show up as a package in the Mathematica add-ons. 

![QMRITools package](https://github.com/mfroeling/QMRITools/blob/master/Images/AddOns.PNG)

All code and documentation is maintained and uploaded to github using [Workbench](https://www.wolfram.com/workbench/).

![Guides QMRITools](https://github.com/mfroeling/QMRITools/blob/master/Images/Guide.PNG)

An online version of the full documentation can be found [here](\QMRITools\htmldoc\guide\QMRITools.html){:target="_blank"}

## Install toolbox

The latest release can be found [here](https://github.com/mfroeling/QMRITools/releases/download/2.0/QMRITools.zip). 

Install the toolbox in the Mathematica UserBaseDirectory > Applications.

	FileNameJoin[{$UserBaseDirectory, "Applications"}]

Some functions of QMRITools call on external executables and software.
These executables need to be present in "QMRITools\Applications" and are included in the release.
If for any reason you want to use other (older/newer) versions you can replace them but functionality is not guaranteed.
For the latest version of these tools and their user license please visit their website.

* [dcm2niix](https://github.com/rordenlab/dcm2niix/)
	* dcm2niix.exe
* [Elastix](http://elastix.isi.uu.nl/)
	* elastix.exe
	* transformix.exe

All functionality is tested under Windows 10 with the latest Mathematica version.
The Mathematica code is cross platform compatible with the exception of the external tools which are compiled for each OS.
The toolbox provides compiled versions for each OS but their functionality is not guaranteed.
The Elastix version used is 4.9 with OpenCL support. Additionally Elastix needs to be compiles with the PCA metrics, all DTI related parameters and all affine related parameters.

Although cross platform compatibility is provided I have only limited options for testing so if any issues arise please let me know.  

## Demonstrations

The release contains a zip file [DemoAndTest.zip](https://github.com/mfroeling/QMRITools/releases/download/2.0/DemoAndTest.zip) in which there is a file ``demo.nb``, a folder ``DemoData`` and a folder ``Testing``. 
To have a global overview of the functionality of the toolbox you can download this folder and run the ``demo.nb``.
By default the ``demo.nb`` looks for the folders ``DemoData`` and ``Testing`` in the same folder as the notebook.

In the first section of the demo notebook the toolbox is loaded and two tests are performed. The first test is to check of all files that are needed to run the toolbox are present. The second test runs after the toolbox is loaded and checks if all the functions and their options that are defined are correct.
 

## Using the toolbox

The toolbox can be loaded by using `` <<QMRITools` ``

A list of all QMRITools packages is generated by 
	
	QMRIToolsPackages[]

A list of all DTITools functions or functions per toolbox is generated by 

	QMRIToolsFunctions[]
	QMRIToolsFunctions["toolboxname"]
	
To print the documentation of all functions use

	QMRIToolsFuncPrint[]
	QMRIToolsFuncPrint["toolboxname"]

A list off all functions and their help can be found in ``All-Functions.nb``, which is alos availible as a [pdf file](https://github.com/mfroeling/QMRITools/releases/download/2.0/All-Functions.pdf).

## Functionality

The toolbox contains over 250 Functions and options of processing and analyzing data.
A summary of the core functionality is listed below. 

![Overview](https://github.com/mfroeling/QMRITools/blob/master/Images/OverView.jpg)

* **Diffusion Analysis**
	* Signal drift correction 
	* LLS, WLLS and iWLLS methods
	* REKINDLE outlier detection
	* IVIM fitting (fixed parameters, back-projection and Bayesian fitting)
	* Parameter fitting using histogram analysis
	* Joining and sorting of multiple series of the same volume
	* Joining multiple stacks with slice overlap into one stack
* **Diffusion Gradients optimization**
	* Single and multi shell
	* Rotating and correcting Bmatrix
	* Actual b-value estimation by gradient sequence integration
	* Gradient visualization
* **Noise suppression**
	* LMMSE noise suppression
	* PCA noise suppression based on ramom matrix theory
	* Anisotropic tensor smoothing using diffusion filter.
* **Importing and Exporting**
	* Dicom data (classing and enhanced file format)
	* Nifti data (.nii and .img .hdr, supports .gz files)
	* Compatible with ExplorDTI and Viste for fiber tractography
* **Data visualization**
	* 2D 3D and 4D viewer
	* Multiple images: Transparent overlay, difference and, checkboard overlays
	* Legend bars and image labels
	* Saving to pdf, jpg, animated gif and movie
* **Masking**
	* Automate and threshold masking
	* Extracting parameters form masks
	* Smoothing masks
	* Smoothing muscle segmentation
* **Motion and distortion correction (Registration using elastix)**
	* Rigid, affine, b-spline and cyclic registration 
	* nD to nD registration
	* Automated series processing 
	* Slice to slice motion correction of 3D and 4D data
* **Dixon Reconstruction**
	* B0 phase unwrapping
	* DIXON iDEAL reconstruction with T2start
* **Relaxometry fitting**
	* T2 fitting
	* T1rho fitting
	* Tri Exponential T2 fitting
	* EPG based T2 fitting with slice profile
* **Simulation Framework**
	* Diffuison tensor simulation and analysis
	* Bloch and EPG simulations
	* Cardiac DTI models (fiber architecture)
* **Cardiac Diffusion analysis** 
	* Breathing motion correction
	* Corrupted slice rejection
	* Local myocardial coordinate system calculation
	* helix angle and fiber architecture matrix
	* AHA 17 parameter description
	* Transmural parameter description	
	
## License
https://opensource.org/licenses/BSD-3-Clause

Note that restrictions imposed by these patents (and possibly others)
exist independently of and may be in conflict with the freedoms granted
in BSD-3-Clause license, which refers to copyright of the program, not patents
for any methods that it implements. Both copyright and patent law must
be obeyed to legally use and redistribute this program and it is not the
purpose of this license to induce you to infringe any patents or other
property right claims or to contest validity of any such claims.  If you
redistribute or use the program, then this license merely protects you
from committing copyright infringement.  It does not protect you from
committing patent infringement.  So, before you do anything with this
program, make sure that you have permission to do so not merely in terms
of copyright, but also in terms of patent law.

Some code in the NiiTools packages was based on https://github.com/tomdelahaije/nifti-converter
