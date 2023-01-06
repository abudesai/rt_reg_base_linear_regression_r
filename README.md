# General Linear Regression Algorithm in R as per Ready Tensor specifications

## Description

this repo was built as per Ready Tensor specifications to

1. Read training data using data schema
2. Preprocess training data for Regression problem
3. Train XGB model on the dataset and save the model
4. Test the saved model
5. Create endpoint to use the model through API

## Try the algorithm

1. Build the docker image
2. when you run the image use volume to specify

- when training ( directory of training data and data schema , directory to save the model in)
  docker run -v <mounted_ml_dir_on_host>:/opt/ml_vol --rm <image_name> train

- when testing ( directory of testing data , directory to load the model from)
  docker run -v <mounted_ml_dir_on_host>:/opt/ml_vol --rm <image_name> predict

- when serving ( directory to load the model from)
  docker run -v <mounted_ml_dir_on_host>:/opt/ml_vol -p 8080:8080 --rm <image_name> serve

## Data schema

See Ready Tensor specifications.

## Data preprocessing

The data preprocessing step includes missing data imputation, target encoding for categorical variables,
datatype casting, etc. The missing categorical values are imputed using the most frequent value . Missing numerical values are imputed using the mean.
data was split by 70% train to 30% validation to use with hyperparameter tuning.

the algorithm was trained and evaluated on a variety of datasets such as email spam detection, customer churn, credit card fraud detection,
cancer diagnosis, and titanic passanger survivor prediction

This Regression Model is written using R as its programming language. R package general linear model is used to implement the main algorithm,
evaluate the model, and preprocess the data. tidyverse, and feature_engine are used for the data preprocessing steps.
Plumber are used to provide web service which includes three endpoints- /ping for health check,
/infer for predictions.
