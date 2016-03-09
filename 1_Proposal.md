
### Summary
Smart watches and prototype wrist-worn devices are capable of monitoring the acceleration of a sleeping individual. These wearable computers generate an enormous amount of data, recording coordiantes every second of the day. The goal of this project is to investitage abnormal movement patterns associated with sleep disorders. Although this project is exploratory in nature, patterns identified under this analysis could be attractive to developers in the wearable industry. 

### Data
Raw sleep data has been obtained from 42 participants, some have sleep disorders. The data is publically availble: http://www.ess.tu-darmstadt.de/ichi2014

### Capstone Project Overview
--- Convert data from .NumPy to csv  
--- Filter raw data (Butterworth band-pass filter for movement); Fig2 in paper  
--- Plot XYZ inertia/movement (raw filtered data); Fig5 in paper  
--- Apply the ESS sleep detection algorithm; Fig5 in paper  
--- Compare prediction of movement to clinical data by accuracy; Fig8 in paper  
--- Apply supervised machine learning to test whether predictions are more accurate than the manuscript's algorithm

### Deliverables
Paper write up and code
