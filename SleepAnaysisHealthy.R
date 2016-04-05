# Sleep Data Analysis
# Casandra Philipson

# Analysis for a Healthy Patient

#Import data, fix timestamp
sleep <- tidyfile("p033.csv")
sleep <- fixtime(sleep)

#Butterworth filter
sleepb <- mybutter(sleep)

#Feature engineering
sleep_int <- featuremetrics(sleepb) #Metrics
sleep_freq <- featureFFT(sleepb) #FFT
sleep_freq$timestamp <- sleep_int$timestamp #re-align timestamp
sleep_int <- full_join(sleep_int, sleep_freq, by = "timestamp") #combine features
sleep_pred <- baselinemodel(sleep_int) #Baseline predicitions for activity

#Prepare for training model
sleep_model <- dplyr::filter(sleep_pred, ground_truth > 0) %>%
  mutate(gt_model = ifelse(ground_truth >= 5, 1, 0))

#In patient classification of sleep using Random forest and Cross validation
sleep_model$gt_model <- as.factor(sleep_model$gt_model)
trControl <- trainControl(method = "cv", number = 10)
train <- createDataPartition(sleep_model$gt_model, p = 0.7, list = FALSE)
test <- sleep_model[-train,]

sleepForestCV <- train(gt_model ~ bfz.absolute + duration.norm + magnitude, data = sleep_model, method = "rf", metric = "Kappa", trControl = trControl, subset = train)

test$pred.rf <- predict(sleepForestCV, test, "raw")
confusionMatrix(test$pred.rf, test$gt_model)

#Get all data for visualization
sleep_model$pred.rf <- predict(sleepForestCV, sleep_model, "raw")
