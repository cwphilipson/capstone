# capstone
Characterizing sleep disorders using data from smart watch  
## Files:  
1_ProposalCapstone : preliminary proposal  
Springboard-Capstone.docx: final report  
Springboard-Capstone.pptx: final figures with brief summary as presentation
  
  
## Data:  
All patient data for this project is open-source and can be found here: http://www.ess.tu-darmstadt.de/ichi2014  
Model performance data obtained from my analysis is contained in SleepAnalysisModelResults.csv  
  
  
## Code:  
SleepAnalysisCondensed.R : uploads functions, runs analysis on healthy patient, creates visualizations  
SleepAnalysisFunctions.R : detailed file containing functions I made and library needed for analysis (can be run independently)  
SleepAnalysisHealthy.R : imports and tidys data, performs feature engineering, builds a random forest model (requires SleepAnalysisFunction.R)  
SleepAnalysisVisualization: creates figures 1, 4, 5, and 6 from report (requires SleepAnalysisHealthy.R)  
SleepAnalysisStatistics.R : combines data from 5 heathy and 5 sick patients, performs basic exporatory analysis, creates figures 2 and 3 from report (requires SleepAnalysisFunction.R)  

Run in order:  
SleepAnalysisFunctions.R, SleepAnalysisHealthy.R, SleepAnalysisVisualization, SleepAnalysisStatistics.R  
(To analyze data from different patients, edit the read.csv line in SleepAnalysisHealthy.R)  
