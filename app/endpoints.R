
## Script that holp helper functions
source('algorithm/0.common_funcs.R')

## ---- Initialising libraries ----
suppressWarnings(suppressMessages(library(tidyverse)))
suppressWarnings(suppressMessages(library(lubridate)))
suppressWarnings(suppressMessages(library(data.table)))
suppressWarnings(suppressMessages(library(httr)))
suppressWarnings(suppressMessages(library(glue)))

## Load model
trained_model  <- read_rds('/opt/ml_vol/model/artifacts/model.rds')
variables_to_encode   <- trained_model$variables_to_encode
id_column             <- trained_model$id_column
exp_vars              <- trained_model$exp_vars
encodings             <- trained_model$encodings
variables_numeric     <- trained_model$variables_numeric
id_column             <- trained_model$id_column



#* @post /infer
#* @serializer json list(auto_unbox=TRUE)
function(req) {

  ## grab the request body 'req' and put it into the variable 'row'
  inference_data = jsonlite::fromJSON(req$postBody)$instances 
  
  ## parameters that we need
  necessary_params <- exp_vars
  
  ## if we do NOT have all we need...
  if (!all(necessary_params %in% names(inference_data))) {
    list(
      "prediction" = 0,
      "warnings" = 'Some necessary features are missing'
    )    
    
  } else {
    
    ## if any of the necessary parameters are null...
    if (inference_data %>% sapply(is.null) %>% any()) {

      list(
        "prediction" = 0,
        "warnings" = paste('The following required parameters were NULL:', null_parameters)
      )      
      
    } else {
      predictions = get_predictions(trained_model, inference_data)      
    }
    print("Done with predictions. Returning predictions...")
    
    list(
      "status" = "success",
      "code" = 200,
      "predictions" = predictions
    )
    
  }
  
}



#* @get /ping
#* @serializer json list(auto_unbox=TRUE)
endpoint.healthz <- function(req) {
  return("This XGB model service is listening for requests!")
}
