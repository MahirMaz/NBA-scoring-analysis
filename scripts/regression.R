# 1. Load required libraries
library(readxl)
library(dplyr)
library(caret)
library(ggplot2)

# 2. Load dataset (run this script with the working directory set to the project root)
nba <- read_excel("data/NBA Player Box Score Stats (1950-2022).xlsx")

# 3. Select relevant columns
nba <- nba %>%
  select(PTS, Season, MIN, FGA, FG3A, FTA,
         FG_PCT, FG3_PCT, FT_PCT,
         AST, REB, TOV, BLK, STL)

# 4. Filter players who played at least 3 minutes
nba <- nba %>% filter(MIN >= 3)

# 5. Remove rows with missing values
nba <- na.omit(nba)

# 6. Create 'decade' column from season
nba$decade <- floor(nba$Season / 10) * 10

# 7. Partition data (70% train, 30% test), stratified by decade
set.seed(123)
trainIndex <- createDataPartition(nba$decade, p = 0.7, list = FALSE)
train <- nba[trainIndex, ]
test  <- nba[-trainIndex, ]

# 8. Define predictors and response variable
predictor_cols <- c("MIN", "FGA", "FG3A", "FTA",
                    "FG_PCT", "FG3_PCT", "FT_PCT",
                    "AST", "REB", "TOV", "BLK", "STL")
response_col <- "PTS"

# 9. Normalize predictors
pre_proc <- preProcess(train[, predictor_cols], method = c("center", "scale"))
train_norm <- predict(pre_proc, train[, predictor_cols])
test_norm <- predict(pre_proc, test[, predictor_cols])

# 10. Add target variable back to normalized sets
train_norm$PTS <- train$PTS
test_norm$PTS <- test$PTS

# 11. Train Linear Regression model
lm_model <- train(PTS ~ ., data = train_norm, method = "lm")

# 12. Predict on test set
lm_predictions <- predict(lm_model, newdata = test_norm)

# 13. Evaluate model performance
lm_rmse <- RMSE(lm_predictions, test_norm$PTS)
lm_r2 <- R2(lm_predictions, test_norm$PTS)
cat("Linear Regression RMSE:", lm_rmse, "\n")
cat("Linear Regression R²:", lm_r2, "\n")

# 14. Check variable importance
importance <- varImp(lm_model, scale = TRUE)
print(importance)

# 15. Plot variable importance
ggplot(importance, aes(x = reorder(rownames(importance$importance), Overall), y = Overall)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  coord_flip() +
  labs(title = "Variable Importance (Linear Regression)",
       x = "Predictor",
       y = "Importance")
