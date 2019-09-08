#!/bin/bash

#===================================================================
# GENERAL INSTALLATION SCRIPT
#===================================================================


# ttab library install
npm install -g ttab

##################################################
# PYTHON3 LIBRARIES
##################################################
pip3 install Scrapy
pip3 install selenium

# MATLAB install
bash Math/mathematica/mathematica.sh "../../Backups/mathematica.txt"

# Mathematica install
bash Math/matlab/matlab.sh "../../Backups/matlab.txt"
