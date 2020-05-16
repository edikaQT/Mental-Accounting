
# The red, the black, and the plastic: paying down credit card debt for hotels not sofas

These instructions will help you replicate the figures and tables in Quispe Torreblanca E G, Stewart N, Gathergood J, Loewenstein G (in press) [The red, the black, and the plastic: paying down credit card debt for hotels not sofas.](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3037416)

Published in Management Science
 
## Getting Started

These files replicate all of the figues and tables in the paper.

The STATA file sequence is controlled by the Master_Mental_Accounting do file.

Set the globals at the top of the file to your local directory locations. 

The master file will then call in the slave do files to reproduce figures and tables

## Note on the DATA

If you have the Argus data used in the study, place it in the location_data target folder and comment out the SIMULATING RANDOM DATA lines

You will then need to run the R scripts Mental_Accounting_Initial_Data_Cleaning and Mental_Accouhnting_Subseting_Multiple_Card_Holders

If you do not have the Argus data but would like to run the code on simulated data, leave the simulation lines live in the code.
