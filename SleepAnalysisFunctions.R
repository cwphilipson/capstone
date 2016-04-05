############### LOAD LIBRARIES #################
suppressMessages(library(dplyr))
suppressMessages(library(tidyr))
suppressMessages(library(reshape))
suppressMessages(library(signal))
suppressMessages(library(caTools))
suppressMessages(library(xts))
suppressMessages(library(ggplot2))
suppressMessages(library(data.table))
suppressMessages(library(randomForest))
suppressMessages(library(caret))
suppressMessages(library(rpart))
suppressMessages(library(rpart.plot))
suppressMessages(library(e1071))
suppressMessages(library(gridExtra))
suppressMessages(library(lubridate))

############### IMPORT DATA FUNCTION ############### 

tidyfile <- function(x) {
  read.csv(x, header = FALSE, sep = ",", 
           col.names = c("timestamp", "runlength", "x", "y", "z", "light_sensor", "ground_truth"), 
           colClasses = c("factor", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"))
  }

################ FIX TIMESTAMP FUNCTION ############### 

fixtime <- function(df){
  df$timestamp = structure(df$timestamp, class = c("POSIXct"))
  t = strftime(df$timestamp, format = "%H:%M:%S")
  df$timestamp = as.POSIXct(t, format = "%H:%M:%S")
  return(df)
  }

############### BUTTERWORTH FILTER FUNCTION ############### 

mybutter <- function(df){
  cutOff_low = 3 #Frequency in Hz
  cutOff_high = 11 #Frequency in Hz
  Fs = 100 # Frequency of sampling in Hz
  
  cutLowrad = cutOff_low*(2*pi/Fs)
  cutHighrad = cutOff_high*(2*pi/Fs)
  W = c(cutLowrad/2, cutHighrad/2)
  
  n = 1 # Filter order
  
  bf = butter(n, W, type = "pass", plane = "z")
  
  df$bf.x = filtfilt(bf, df$x)
  df$bf.y = filtfilt(bf, df$y)
  df$bf.z = filtfilt(bf, df$z)
  
  return(df)
  }

############### FEATURE METRIC FUNCTIONS ############### 

RMSfun <- function(x){
  sqrt(mean(x^2))
  }

featuremetrics <- function(df) {
  # Running Standard Deviation
  k_sd = 30 # window size in seconds
  df$run.sd <- runsd(df$bf.z, k_sd, center = runmean(df$bf.z,k_sd), endrule = "keep", align = "center")
  
  sleepxts = xts(df[,-1], order.by = df[,1]) #xts for time analysis
  sleep.bfz.xts = xts(df[,"bf.z"], order.by = df[,1]) #only bfz for sd
  k = 15 # interval in seconds for analysis
  ep = endpoints(sleepxts, 'secs', k = k) # second interval
  
  #FEATURES
  int_mean = period.apply(sleepxts, INDEX = ep, FUN = colMeans) # interval mean
  int_max = period.max(sleepxts$bf.z, INDEX = ep) # interval max
  int_min = period.min(sleepxts$bf.z, INDEX = ep) # interval min
  int_sd = period.apply(sleep.bfz.xts, INDEX = ep, FUN = sd) # interval std dev
  int_RMS = period.apply(sleep.bfz.xts, INDEX = ep, FUN = RMSfun) # RMS
  
  # Merge new xts into data.frame
  new_df <- data.frame(timestamp = index(int_mean), coredata(int_mean),
                       coredata(int_max), coredata(int_min), coredata(int_sd), coredata(int_RMS))
  
  #FEATURES
  new_df <- mutate(new_df, range = coredata.int_max. - coredata.int_min.) %>% #Range of max-min
    mutate(ratio = coredata.int_max. / coredata.int_min.) %>% #Ratio of max/min
    mutate(bfz.absolute = abs(bf.z)) #Absolute value of bf.z
  
  #Fix ground_truth (since it got averaged)
  ground_truth <- df$ground_truth[seq.int(1, length(df$ground_truth), k)]
  new_df$ground_truth <- ground_truth
  
  return(new_df)
}

############### FAST FOURIER TRANSFORM FUNCTIONS ############### 

featureFFT <- function(df){ 
  #Calculate FFT and magnitude over intervals
  sleep_fft <- df %>%
    mutate(interval = floor_date(timestamp, unit = "minute") + seconds(floor(second(timestamp)/15)*15)) %>%
    group_by(interval) %>% 
    mutate(sleepfft = fft(bf.z)) %>%
    mutate(magnitude = Mod(bf.z))
  
  #Extract highest frequency for each interval
  k <- 15 # time interval from FFT calculation
  fq <- 1:k/k #calculate frequency
  sleep_fft$freq <- rep(fq, length.out = (length(sleep_fft$magnitude))) #label all freq
  
  sleep_freq <- sleep_fft %>%
    select(freq, magnitude, interval) %>%
    group_by(interval) %>%
    slice(which.max(magnitude))
  
  return(sleep_freq)
}

############### BASELINE MODEL PREDICTIONS ############### 

baselinemodel <- function(df){
  # Baseline prediction for sleep
  df$base.pred <- ifelse((df$bf.z - mean(df$bf.z))^2 < df$run.sd, 1, 0) # 1 = stationary, 0 = movement
  
  # Calculate durration of activity cycles
  setDT(df)
  df[, run := cumsum(c(1, diff(base.pred) != 0))]
  sleep_duration <- (df[, list(duration = difftime(max(timestamp), min(timestamp), unit = "secs")), by = run])
  
  sleep_pred <- full_join(df, sleep_duration, by = "run") %>%
    mutate(duration = as.numeric(duration, unit = "secs")) %>%
    mutate(duration.norm = sqrt(duration))
  
  return(sleep_pred)
}