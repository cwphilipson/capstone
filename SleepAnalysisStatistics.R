# Load functions and libraries
source('~/SleepAnalysisFunctions.R')

#Import data
sleep1 <- tidyfile("p033.csv")
sleep1 <- fixtime(sleep1)
sleep1 <- mybutter(sleep1)
sleep1 <- dplyr::filter(sleep1, ground_truth > 0) %>%
  mutate(disorder = "heathy") %>%
  mutate(patient = 33)

sleep2 <- tidyfile("p08a.csv")
sleep2 <- fixtime(sleep2)
sleep2 <- mybutter(sleep2)
sleep2 <- dplyr::filter(sleep2, ground_truth > 0) %>%
  mutate(disorder = "heathy")%>%
  mutate(patient = 8.1)

sleep3 <- tidyfile("p034.csv")
sleep3 <- fixtime(sleep3)
sleep3 <- mybutter(sleep3)
sleep3 <- dplyr::filter(sleep3, ground_truth > 0) %>%
  mutate(disorder = "heathy")%>%
  mutate(patient = 34)

sleep4 <- tidyfile("p051.csv")
sleep4 <- fixtime(sleep4)
sleep4 <- mybutter(sleep4)
sleep4 <- dplyr::filter(sleep4, ground_truth > 0) %>%
  mutate(disorder = "heathy")%>%
  mutate(patient = 51)

sleep5 <- tidyfile("p007.csv")
sleep5 <- fixtime(sleep5)
sleep5 <- mybutter(sleep5)
sleep5 <- dplyr::filter(sleep5, ground_truth > 0) %>%
  mutate(disorder = "SAS")%>%
  mutate(patient = 7)

sleep6 <- tidyfile("p011.csv")
sleep6 <- fixtime(sleep6)
sleep6 <- mybutter(sleep6)
sleep6 <- dplyr::filter(sleep6, ground_truth > 0) %>%
  mutate(disorder = "SAS")%>%
  mutate(patient = 11)

sleep7 <- tidyfile("p019.csv")
sleep7 <- fixtime(sleep7)
sleep7 <- mybutter(sleep7)
sleep7 <- dplyr::filter(sleep7, ground_truth > 0) %>%
  mutate(disorder = "SAS")%>%
  mutate(patient = 19)

sleep8 <- tidyfile("p028.csv")
sleep8 <- fixtime(sleep8)
sleep8 <- mybutter(sleep8)
sleep8 <- dplyr::filter(sleep8, ground_truth > 0) %>%
  mutate(disorder = "SAS")%>%
  mutate(patient = 28)

sleep9 <- tidyfile("p037.csv")
sleep9 <- fixtime(sleep9)
sleep9 <- mybutter(sleep9)
sleep9 <- dplyr::filter(sleep9, ground_truth > 0) %>%
  mutate(disorder = "SAS")%>%
  mutate(patient = 37)

sleep10 <- tidyfile("p08b.csv")
sleep10 <- fixtime(sleep10)
sleep10 <- mybutter(sleep10)
sleep10 <- dplyr::filter(sleep10, ground_truth > 0) %>%
  mutate(disorder = "heathy")%>%
  mutate(patient = 8.2)

# Combine all data
sleep_combined <- bind_rows(sleep1, sleep2, sleep3, sleep4, sleep5, sleep6, sleep7, sleep8, sleep9, sleep10)

# Label ground_truth sleep features
sleep_combined <- within(sleep_combined, ground_truth_label <- factor(sleep_combined$ground_truth, labels = c("sleep3", "sleep2", "sleep1", "REM", "awake", "movement")))

#Calculate total time spent in each phase
sleep_time <- dplyr::filter(sleep_combined, ground_truth < 6) #sleeping only

setDT(sleep_time)
sleep_time[, run := cumsum(c(1, diff(ground_truth) > 0 ))]
sleep_duration <- (sleep_time[, list(sleep.duration = difftime(max(timestamp), min(timestamp), unit = "secs")), by = run])

sleep_time <- full_join(sleep_time, sleep_duration, by = "run") %>%
  mutate(sleep.duration = as.numeric(sleep.duration, unit = "secs"))

sleep_time_summary <- sleep_time %>%
  group_by(disorder, patient, ground_truth_label, ground_truth) %>%
  summarise(sleep.time = sum(sleep.duration))

sleep_time_summary2 <- sleep_time %>%
  group_by(patient) %>%
  summarise(sleep.total = sum(sleep.duration))

sleep_time_summary3 <- full_join(sleep_time_summary, sleep_time_summary2, by = "patient") %>%
  mutate(percent.time = (sleep.time/sleep.total)*100)

#ANOVA
sleep_anova <- aov(percent.time ~ disorder + ground_truth_label, data = sleep_time_summary3)

#Visualize
p5a <- ggplot(data = sleep_combined, aes(x = ground_truth_label, y = bf.z, group = ground_truth)) + 
  facet_wrap(~disorder) +
  stat_boxplot(geom = 'errorbar') +
  geom_boxplot(aes(fill = ground_truth_label), outlier.size = NA) +
  scale_fill_brewer(palette = "GnBu") +
  coord_cartesian(ylim = c(-4, 4)) + 
  theme_minimal()

p5b <- ggplot(data = sleep_time_summary3, aes(x = ground_truth_label, y = percent.time, group = ground_truth_label)) + 
  facet_wrap(~disorder) +
  stat_boxplot(geom = 'errorbar') +
  geom_boxplot(aes(fill = ground_truth_label), outlier.size = NA) +
  scale_fill_brewer(palette = "Greens") +
  coord_cartesian(ylim = c(0, 100)) + 
  theme_minimal()