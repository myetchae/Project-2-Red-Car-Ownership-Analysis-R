# Red Car Ownership Analysis
# Run from the repository root (where data.csv is located)

library(tidyverse)
library(ggplot2)
library(forcats)

# -----------------------------
# 1) Read data
# -----------------------------
claim_data <- read.csv("data.csv")

# -----------------------------
# 2) Select 5 features
# -----------------------------
work_data <- claim_data[, c("AGE", "MSTATUS", "SEX", "EDUCATION", "RED_CAR")]

# -----------------------------
# 3) Clean categories
# -----------------------------
# Standardise marital status
work_data$MSTATUS <- as.factor(work_data$MSTATUS)
levels(work_data$MSTATUS) <- gsub("^z_", "", levels(work_data$MSTATUS))  # z_No -> No, etc.

# Standardise sex labels
work_data$SEX <- as.factor(work_data$SEX)
work_data$SEX <- fct_collapse(work_data$SEX, F = c("z_F"))

# -----------------------------
# 4) Create age groups
# -----------------------------
work_data$agegroup <- cut(
  work_data$AGE,
  breaks = c(0, 35, 50, 100),
  labels = c("less than 35", "35 to 50", "more than 50")
)

# -----------------------------
# 5) Summary table by age group
# -----------------------------
red_car_stats <- table(work_data$agegroup, work_data$RED_CAR)
mstatus_stats <- table(work_data$agegroup, work_data$MSTATUS)
total_cars <- table(work_data$agegroup)

output <- cbind(total_cars, red_car_stats[, "yes"], mstatus_stats[, "Yes"])
output <- data.frame(output)

colnames(output) <- c("Total_Cars", "Red_Cars", "Marital_Status")

output$red_car_percent <- round(output$Red_Cars / output$Total_Cars * 100, 2)

print(output)

write.csv(output, "output.csv", row.names = TRUE)

# -----------------------------
# 6) Visualisations
# -----------------------------
dir.create("images", showWarnings = FALSE)

# (1) AGE boxplot
p1 <- ggplot(work_data, aes(y = AGE)) +
  geom_boxplot() +
  labs(title = "Age distribution (boxplot)", y = "Age", x = NULL)
ggsave("images/01_age_boxplot.png", p1, width = 6, height = 4, dpi = 200)

# (2) AGE by SEX
p2 <- ggplot(work_data, aes(x = SEX, y = AGE)) +
  geom_boxplot() +
  labs(title = "Age by Sex (boxplot)", x = "Sex", y = "Age")
ggsave("images/02_age_by_sex_boxplot.png", p2, width = 6, height = 4, dpi = 200)

# (3) AGE by EDUCATION
p3 <- ggplot(work_data, aes(x = EDUCATION, y = AGE)) +
  geom_boxplot() +
  labs(title = "Age by Education (boxplot)", x = "Education", y = "Age") +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))
ggsave("images/03_age_by_education_boxplot.png", p3, width = 8, height = 4.5, dpi = 200)

# (4) AGE by SEX, coloured by EDUCATION
p4 <- ggplot(work_data, aes(x = SEX, y = AGE, colour = EDUCATION)) +
  geom_boxplot(outlier.colour = "red") +
  labs(title = "Age by Sex and Education (boxplot)", x = "Sex", y = "Age")
ggsave("images/04_age_by_sex_and_education_boxplot.png", p4, width = 7.5, height = 4.5, dpi = 200)
