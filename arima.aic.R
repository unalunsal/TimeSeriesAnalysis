
library("quantmod")
library("parallel")
library("rugarch")
library("datasets")
library("crayon")
library("forecast")

#Define a function to delete NAs.There will be NAs in the retreived data 
delete.na <- function(DF, n=0) {
  DF[rowSums(is.na(DF)) <= n,]
}

# Define another function that selects the optimum AR(p) and MA(q) parameters and the Integration (d)
# based on Information Criterion (AIC or BIC).
# This function will be called by the function below since I will be updating ARIMA(p,d,q) orders for each training sets.
orderSelect <- function(df.train, infoCrea){
  final.ic = Inf
  final.order.ic = c(0,0,0)
  
  for (p in 0:6) for (d in 1:2) for (q in 0:6) {
    mod.ic = arima(df.train,order = c(p,d,q), method='ML',optim.control = list(maxit = 9999999), include.mean = TRUE)
    current.ic = infoCrea(mod.ic)

    if (current.ic < final.ic) {
      final.ic = current.ic
      final.order.ic = c(p,d,q)
      fit.ic = mod.ic
    }
  }
  return(final.order.ic)
}


# Function that calculates the out of sample recursive RMSE value.
# SYMBOL: First Component of the function is the symbol for the time series data that will be retreived from the data source.
# SOURCE: Second Component of the function which is the data source (ex; FRED, YAHOO)
# testRatio: Third Component of the function which is the train set / test set ratio
# infoCrea: Information criteria that will be used to choose optimum lags for the ARIMA (p,d,q) model.
#           (ex; AIC: Akaike Information Criteria or BIC: Bayesian Information Criteria)

recursive <- function(SYMBOL, SOURCE,testRatio, infoCrea) {
  df = getSymbols(SYMBOL,src= SOURCE,auto.assign = getOption('loadSymbols.auto.assign',FALSE))
  df = as.vector(delete.na(df))

  for (i in round(length(df)*testRatio):(length(df)-1)){
    df.train = df[0:i]
    df.test = df[(i+1):length(df)]
    pqorder = orderSelect(df.train, infoCrea)
    p = pqorder[1]
    d = pqorder[2]
    q = pqorder[3]
    mod.ic = arima(df.train,order = c(p,d,q), method='ML',optim.control = list(maxit = 9999999), include.mean = TRUE)
    fore = predict(mod.ic, length(df.test))$pred
    rmse = sqrt(mean((df.test - fore)^2))
    print(paste("# of rows in the training set:",length(df.train), ", Selected ARIMA(",p,d,q,")",", Out of sample RMSE: ", rmse))
  }
}

recursive("DEXUSEU", "FRED", 0.5, AIC)



