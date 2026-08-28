# Load required libraries
library(readxl)
library(dplyr)
library(caret)
library(FNN)
library(ggplot2)
library(Metrics)

# 1. Load data (run this script with the working directory set to the project root)
nba <- read_excel("data/NBA Player Box Score Stats (1950-2022).xlsx")

# 2. Select relevant columns
nba <- nba %>%
  select(PTS, Season, MIN, FGA, FG3A, FTA,
         FG_PCT, FG3_PCT, FT_PCT,
         AST, REB, TOV, BLK, STL)

# 3. Filter and clean
nba <- nba %>% filter(MIN >= 3)
nba <- na.omit(nba)
nba$decade <- floor(nba$Season / 10) * 10

# 4. Split data
set.seed(123)
trainIndex <- createDataPartition(nba$decade, p = 0.7, list = FALSE)
train <- nba[trainIndex, ]
test  <- nba[-trainIndex, ]

# 5. Normalize predictors
predictor_cols <- c("MIN", "FGA", "FG3A", "FTA",
                    "FG_PCT", "FG3_PCT", "FT_PCT",
                    "AST", "REB", "TOV", "BLK", "STL")

pre_proc <- preProcess(train[, predictor_cols], method = c("center", "scale"))
train_norm <- predict(pre_proc, train[, predictor_cols])
test_norm <- predict(pre_proc, test[, predictor_cols])
train_norm$PTS <- train$PTS
test_norm$PTS <- test$PTS

# --- kNN MODELING (Faster Version) ---

# 6. Choose k with 5-fold cross-validation on the TRAINING set only.
#    The test set is not touched here; it is held out for the final evaluation
#    below, so the reported test performance is not biased by tuning.
k_values <- c(3, 7, 11)

set.seed(123)
folds <- createFolds(train_norm$PTS, k = 5)

cv_rmse <- sapply(k_values, function(k) {
  fold_rmse <- sapply(folds, function(val_idx) {
    tr  <- train_norm[-val_idx, ]
    val <- train_norm[val_idx, ]
    preds <- knn.reg(train = tr[, predictor_cols],
                     test  = val[, predictor_cols],
                     y = tr$PTS,
                     k = k)$pred
    rmse(val$PTS, preds)
  })
  mean(fold_rmse)
})

# 7. Best k and final model
best_k <- k_values[which.min(cv_rmse)]
cat("Best k:", best_k, "\n")

knn_final <- knn.reg(train = train_norm[, predictor_cols],
                     test = test_norm[, predictor_cols],
                     y = train_norm$PTS,
                     k = best_k)

knn_preds <- knn_final$pred

# 8. Evaluate
knn_rmse <- rmse(test_norm$PTS, knn_preds)
knn_r2 <- 1 - sum((test_norm$PTS - knn_preds)^2) / sum((test_norm$PTS - mean(test_norm$PTS))^2)

cat("kNN RMSE:", knn_rmse, "\n")
cat("kNN R²:", knn_r2, "\n")

# 9. Plot
plot_data <- data.frame(Actual = test_norm$PTS, Predicted = knn_preds)
ggplot(plot_data, aes(x = Actual, y = Predicted)) +
  geom_point(alpha = 0.3) +
  geom_abline(slope = 1, intercept = 0, color = "red") +
  ggtitle(paste("kNN Prediction: Actual vs Predicted (k =", best_k, ")")) +
  theme_minimal()
