# NBA Scoring Analysis

This project looks at how NBA scoring has changed from 1946 to 2023 using game-level box score
data (about 1.3 million player-game records). There are two parts: an interactive Power BI dashboard
that explores scoring trends and individual players, and a set of R scripts that compare a few
statistical models for predicting player scoring.

## Dashboard

Built in Power BI. The `.pbix` file is in `Dashboard/` if you want to open it yourself; the two pages
are below.

### Page 1: Evolution of NBA Scoring

![Page 1: Evolution of NBA Scoring](Dashboard/Page%201%20-%20Evolution%20of%20NBA%20Scoring%2C%201946-2023.png)

This page answers "how has the game changed over time." The lead chart is three-point attempts per
game, which sits at zero until the three-point line was added in 1979-80 and then climbs steadily,
spiking over the last decade. Points per game and shooting percentages sit next to it for context.

The shooting percentage chart is filtered to values under 1.0 (100%). The earliest seasons have
missing or unreliable shot-attempt records, which produced impossible percentages above 100%. Since
you cannot shoot better than 100%, those bad values are filtered out so the real 30 to 80 percent
range is actually readable.

### Page 2: Player Explorer

![Page 2: Player Explorer](Dashboard/Page%202%20-%20Player%20Explorer.png)

This page is driven by the player search box at the top. Pick a player and the whole page updates to
them: career points, best scoring season, and seasons played (the cards), their season-by-season
scoring line, and a table of their individual seasons.

There is no season filter on this page, on purpose. The point of the page is to see one player's whole
career, so filtering by season would cut their trajectory down to a single point. The season control
lives on Page 1, where narrowing the time range actually makes sense.

The player table is limited to seasons with at least 40 games played, so a short or injury-shortened
season with a tiny sample does not distort the numbers.

## Modeling (R)

The `scripts/` folder holds the earlier part of the project: an R comparison of linear regression,
k-nearest neighbors, and decision-tree models for predicting player scoring from box-score stats,
scored with RMSE and R-squared. It was mainly an exercise in comparing modeling approaches and the
trade-off between accuracy and interpretability. For kNN, the k value is chosen with cross-validation
on the training set, with the test set held out for the final score.

## Data

The dataset is the NBA Player Box Score Stats (1950-2022) file from Kaggle: game-level box scores with
player, team, date, and full stat lines. The raw file is too large for GitHub, so it is not committed
here. See `data/SOURCE.md` for where to download it. The dashboard reads from two small aggregated
files in `data/processed/` (one row per season, one row per player-season) that are built from the
raw data.

## Layout

```
Dashboard/        Power BI file and page screenshots
data/             raw data goes here (not committed) and SOURCE.md
data/processed/   aggregated CSVs the dashboard reads from
scripts/          R modeling scripts
report/           original written report
```
