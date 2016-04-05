########################### FIGURE 1 ########################### 
#subset data for plotting
PlotData <- dplyr::filter(sleep, timestamp < "2016-04-04 09:00:00")
PlotData <- dplyr::filter(PlotData, timestamp > "2016-04-04 04:00:00")

#Plot Raw Z-signal
p1a <- ggplot()+
  geom_line(data = PlotData, aes(x = timestamp, y = z), color = "#E18B6B") + 
  geom_line(data = PlotData, aes(x = timestamp, y = x), color = "#29A6A6") +
  geom_line(data = PlotData, aes(x = timestamp, y = y), color = "#808000") +
  theme_minimal() +
  labs(title = "Raw Signals")

p1b <- ggplot()+
  geom_line(data = PlotData, aes(x = timestamp, y = ground_truth), color = "black", size = 0.75) + 
  theme_bw() +
  labs(title = "Ground Truth")

p1c <- ggplot() +
  geom_line(data = PlotData, aes(x = timestamp, y = light_sensor), color = "yellow") +
  theme_dark() +
  labs(title = "Light Sensor")

grid.arrange(p1b, p1a, p1c, ncol = 1)


########################### FIGURE 2 ########################### 
#subset data for plotting
PlotData2 <- dplyr::filter(sleepb, timestamp < "2016-04-04 07:00:00")
PlotData2 <- dplyr::filter(PlotData2, timestamp > "2016-04-04 05:00:00")

#Plot Raw Z-signal
p2a <- ggplot()+
  geom_line(data = PlotData2, aes(x = timestamp, y = z), color = "#E18B6B") + 
  theme_minimal() +
  labs(title = "Raw z-signal")
  
# Plot Filtered Z-signal
p2b <- ggplot() +
  geom_line(data = PlotData2, aes(x = timestamp, y = bf.z), color = "#E18B6B") +
  theme_minimal() +
  labs(title = "Filtered z-signal")

grid.arrange(p2a, p2b, ncol = 1)

########################### FIGURE 3 ###########################  

#subset data for plotting
PlotData3 <- dplyr::filter(sleep_model, timestamp < "2016-04-04 12:00:00")
PlotData3 <- dplyr::filter(PlotData3, timestamp > "2016-04-04 07:00:00")

# Plot Ground Truth
p3a <- ggplot() +
  geom_line(data = PlotData3, aes(x = timestamp, y = ground_truth), size = 1, color = "black") +
  labs(title = "Ground Truth") +
  theme_classic()

# Plot Z with classified ground truth
p3b <- ggplot() +
  geom_point(data = PlotData3, aes(x = timestamp, y = gt_model), shape = 4, color = "#ADD8E6") +
  geom_line(data = PlotData3, aes(x = timestamp, y = bfz.absolute), color = "black") +
  labs(title = "Classified Ground Truth") +
  theme_classic()

# Plot Z with predicted ground truth
p3c <- ggplot() +
  geom_point(data = PlotData3, aes(x = timestamp, y = pred.rf), shape = 5, color = "#4E9258") +
  geom_line(data = PlotData3, aes(x = timestamp, y = bfz.absolute), color = "black") +
  labs(title = "Model Predictions") +
  theme_classic()

grid.arrange(p3a,p3b, p3c, ncol = 1)

########################### FIGURE 4 ###########################  

modelResults <- read.csv("SleepAnalysisModelResults.csv")

modelResults <- modelResults %>%
  mutate(AccuracyIn = AccuracyIn*100) %>%
  mutate(AccuracyOut = AccuracyOut*100) %>%
  mutate(Sensitivity = Sensitivity*100) %>%
  mutate(Specificity = Specificity*100)

p4a <- ggplot(modelResults, aes(x = disorder, y = AccuracyIn)) + 
  geom_boxplot(aes(fill = disorder)) +
  scale_fill_brewer(palette = "Blues") +
  theme_minimal() + 
  theme(legend.position = 'none') +
  labs(title = "Cross Validation Accuracy") + 
  facet_wrap(~window)

p4b <- ggplot(modelResults, aes(x = disorder, y = AccuracyOut)) + 
  geom_boxplot(aes(fill = disorder)) +
  scale_fill_brewer(palette = "Blues") +
  theme_minimal() + 
  theme(legend.position = 'none') +
  labs(title = "Out of sample Accuracy") + 
  facet_wrap(~window)

p4c <- ggplot(modelResults, aes(x = disorder, y = Sensitivity)) + 
  geom_boxplot(aes(fill = disorder)) +
  scale_fill_brewer(palette = "Blues") +
  theme_minimal() + 
  theme(legend.position = 'none') +
  labs(title = "Sensitivity") +
  facet_wrap(~window)

p4d <- ggplot(modelResults, aes(x = disorder, y = Specificity)) + 
  geom_boxplot(aes(fill = disorder)) +
  scale_fill_brewer(palette = "Blues") +
  theme_minimal() + 
  theme(legend.position = 'none') +
  labs(title = "Specificity") + 
  facet_wrap(~window)

p4e <- ggplot(modelResults, aes(x = disorder, y = Kappa)) + 
  geom_boxplot(aes(fill = disorder)) +
  scale_fill_brewer(palette = "Blues") +
  theme_minimal() + 
  theme(legend.position = 'none') +
  labs(title = "Kappa") + 
  facet_wrap(~window)

grid.arrange(p4a, p4b, p4e, p4c, p4d, ncol = 3)
