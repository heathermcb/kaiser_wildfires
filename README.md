# kaiser_wildfires
 some raw data, data cleaning scripts, and analysis for kaiser wildfires project

## Organization

- Things related to, but not necessary for, creation of the final dataset should be stored in the top level folder under an appropriate sub-folder — e.g., eda in `eda`, final models in `analysis`.
- Things that we use to create the final dataset should be kept in the `data_processing` folder in the appropriate sub-folder. E.g., all code should be in `code`, all raw data should be in `raw_data`, etc.
- Raw data are any data we received *before* any editing. Raw data should be considered immutable and therefore should never be edited directly. Any derivatives from the raw data should be kept in `data` and the script that goes from raw data to the derivative data should be kept in `code`.
- We omit some raw data, and the final analytic dataset, from the repo because it's private.
- We omit some other raw data from the repo because it's too big to commit.

Omitted files and where to find and put them:


### RIY (like DIY but Run It Yourself)
- It should be possible to run everything in this repo if you open the files in the R Project in the `data_processing` folder, using the 'here' package, without changing pathnames in the files. EXCEPT the temperature processing bash script (01_temp_proc.sh) and the associated R script (which 01_temp_proc.sh runs). Unfortunately, readOGR (necessary to read the raster files in the temperature processing script) and here() are incompatible. 
- Oh and also the actual raw Kaiser data is omitted so you need that in the raw_data/DMEdatasets20200929172326.