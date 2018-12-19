
library("quantmod")
library("parallel")
library("rugarch")
library("datasets")
library("crayon")
library("forecast")


#Define a function to delete NAs.There will be NAs in the retreived data from data source.
delete.na <- function(DF, n=0) {
  DF[rowSums(is.na(DF)) <= n,]
}

# Function that selects the optimum AR(p) and MA(q) parameters and the Integration (d) value. 
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
# SYMBOL: First Component of the function is the symbol for the time series data
# SOURCE: Second Componenet of the function which is the data source (E.g. FRED, YAHOO)
# testRatio: Third Component of the function which the train set / test set ratio
# infoCrea: Information criteria that will be used to choose optimum lags for the ARIMA model 
#           (E.g. Akaike Information Criterion (AIC), Bayesian Information Criterion (BIC))

recursive <- function(SYMBOL, SOURCE,testRatio, infoCrea) {
  
  df = getSymbols(SYMBOL,src= SOURCE,auto.assign = getOption('loadSymbols.auto.assign',FALSE))
  df = as.vector(delete.na(df))
  rmse = 0 
  for (i in round(length(df)*testRatio):length(df)){
     df.train = df[0:(i-1)]
     df.test = df[i]
     pqorder = orderSelect(df.train, infoCrea) 
     p = pqorder[1]
     d = pqorder[2]
     q = pqorder[3]
     mod.ic = arima(df.train,order = c(p,d,q), method='ML',optim.control = list(maxit = 9999999), include.mean = TRUE)
     rmse = c(rmse, predict(mod.ic,1)$pred - df.test)
     print(rmse)
  }
  return(rmse[2:length(rmse)])
}

rmse = recursive("DEXUSEU", "FRED", 0.5, BIC)

rmse = sqrt ( mean( rmse ^ 2 ) )

print(rmse)



