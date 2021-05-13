# kaiser_wildfires
 some raw data, data cleaning scripts, and analysis for kaiser wildfires project

## CODE FOLDER

- Running all files in order of numbering will produce everything in the data folder.
- Don't run xx files.
- If downloading the repo from GitHub, the only data file that needs to be created is the analytic dataset. Everything else is downloadable. To do this, run 03 only.

- 01 gets the zcta codes in the Kaiser study area and saves them as a csv in the data folder for use in the next two scripts. It uses the Kaiser data. 
- 02 processes temperature data, and gets the mean temperature for each zcta on each day between Jan 1st 2016 and Dec 31st 2019. It uses PRISM data in the raw data folder, and outputs the temperature data into the data folder. It does this by running `xx_temp_proc_zcta_new.R`.
- 03 combines the Kaiser data and processed temperature data (from data folder) as well as corrected PM 2.5 data (from raw data folder) into an analytic dataset, saves in the data folder.
- 04 combines the Kaiser data and processed temperature data (from data folder) as well as corrected PM 2.5 data (from raw data folder) into an analytic dataset for PM models, saves in the data folder.


