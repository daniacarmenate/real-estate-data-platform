# Real Estate Data Platform

A Data Engineering project that demonstrates an end-to-end data pipeline using the USA Real Estate Dataset.

The project covers data profiling, data cleaning, feature engineering, data modeling, and loading the cleaned data into PostgreSQL for analysis.

## Tech Stack

- Python
- Pandas
- NumPy
- PostgreSQL
- SQLAlchemy
- Jupyter Notebook
- Git & GitHub

## Project Structure

```
real-estate-data-platform/
│
├── data/
│   ├── raw/
│   └── processed/
│
├── notebooks/
│   ├── 01_data_profiling.ipynb
│   ├── 02_data_cleaning.ipynb
│   └── 03_database_loading.ipynb
│
├── sql/
├── README.md
└── .gitignore
```

## Dataset

The dataset is not included in this repository because it exceeds GitHub's file size limit.

Download the dataset from Kaggle:

https://www.kaggle.com/datasets/ahmedshahriarsakib/usa-real-estate-dataset

Place the dataset in:

```
data/raw/usa_real_estate.csv
```

## How to Run

Execute the notebooks in the following order:

1. `01_data_profiling.ipynb`
2. `02_data_cleaning.ipynb`
3. `03_database_loading.ipynb`

## Project Status

- ✅ Data Profiling
- ✅ Data Cleaning
- ⏳ Database Loading
- ⏳ SQL Analytics
- ⏳ Data Pipeline