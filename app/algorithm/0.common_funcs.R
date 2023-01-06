

library(tidyverse)
library(lubridate)
library(data.table)
library(dtplyr)
library(tictoc)
library(glue)
library(pROC)
library(caret)
library(Metrics)
library(imputeTS)
options(dplyr.summarise.inform = FALSE)


## *************************

trainer_func <- function(train_set, 
                         validation_set, 
                         explanatory_variables) 
{
  
  print(glue('Hyperparameter tuning begins...'))
  
  model <- lm(label ~ ., data = train_set %>% select(explanatory_variables,label))
  
  val_pred <- predict(model, newdata = validation_set %>% select(explanatory_variables))
  rmse <- rmse(validation_set$label, val_pred)
  
  
  stuff <- list()
  stuff$mdl <- model
  stuff$rmse <- rmse

  return(stuff)
}


## *************************



get_predictions <- function(trained_model, df_test) 
{

  ## various variables
  variables_to_encode   <- trained_model$variables_to_encode
  id_column             <- trained_model$id_column
  exp_vars              <- trained_model$exp_vars
  encodings             <- trained_model$encodings
  variables_numeric     <- trained_model$variables_numeric
  scale_func            <- trained_model$scale_func
  cat_impute_func       <- trained_model$cat_impute_func
  
  # keep this line!!! weird bug in R. code doesnt work without this print! 
  print(encodings)

  id <- df_test %>% select(id_column)  
  
  print("setting up test data..")
  df_test[variables_to_encode] <-
    sapply(df_test[variables_to_encode], as.character)
  df_test[variables_numeric]   <-
    sapply(df_test[variables_numeric], as.numeric)
    
  full_data_numeric <- df_test %>%
    select(-id_column, -variables_to_encode)

  full_data_numeric <- predict(scale_func, as.data.frame(full_data_numeric))
  
    
  print("Encoding test data..")
  if (length(variables_to_encode) != 0)
  {
    full_data_categorical <- df_test  %>% select(variables_to_encode)
    full_data_categorical <- predict(cat_impute_func, as.data.frame(full_data_categorical))
    
    for (i in variables_to_encode) {
      full_data_categorical[[i]] = transform(encodings[[i]], full_data_categorical[[i]])
    }

    full_data_categorical <- full_data_categorical  %>%
      mutate(across(everything(), ~ replace_na(.x, calc_mode(.x))))
    
    df_test <- cbind(id, full_data_numeric, full_data_categorical)
    
  } else{
    df_test <-
      cbind(id, full_data_numeric)
    
  }  

  print("Getting the model..")
  model <- trained_model$mdl
  
  ## Getting probability of each row for the target_class  
  print("Making predictions..")
  print(head(df_test))
  print(trained_model$exp_vars)
  prediction_features <- df_test %>% select(all_of(trained_model$exp_vars))  

  print("prediction_features")
  print(prediction_features)
  print("-----")

  predictions <- predict(model, as.data.frame(prediction_features))
  print("predictions")
  print(head(predictions))
  
  results <- list()
  results[['predictions']] <-
    tibble(prediction = predictions)
    
  predictions <- results$predictions
  predictions <- cbind(id, predictions)

  predictions
}




calc_mode <- function(x) {
  # List the distinct / unique values
  distinct_values <- unique(x)
  
  # Count the occurrence of each distinct value
  distinct_tabulate <- tabulate(match(x, distinct_values))
  
  # Return the value with the highest occurrence
  distinct_values[which.max(distinct_tabulate)]
}
