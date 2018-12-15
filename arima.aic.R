
#install.packages("crayon", lib="C:/Users/unalu/Documents/R/win-library/3.5/library")

library("DBI", lib.loc="C:/Users/unalu/Documents/R/win-library/3.5/library")
library("dplyr", lib.loc="C:/Users/unalu/Documents/R/win-library/3.5/library")
library("implyr", lib.loc="C:/Users/unalu/Documents/R/win-library/3.5/library")
library("odbc", lib.loc="C:/Users/unalu/Documents/R/win-library/3.5/library")
library("zoo", lib.loc="C:/Users/unalu/Documents/R/win-library/3.5/library")
library("TTR", lib.loc="C:/Users/unalu/Documents/R/win-library/3.5/library")
library("xts", lib.loc="C:/Users/unalu/Documents/R/win-library/3.5/library")
library("quantmod", lib.loc="C:/Users/unalu/Documents/R/win-library/3.5/library")
library("parallel", lib.loc="C:/Users/unalu/Documents/R/win-library/3.5/library")
library("rugarch", lib.loc="C:/Users/unalu/Documents/R/win-library/3.5/library")
library("datasets", lib.loc="C:/Users/unalu/Documents/R/win-library/3.5/library")
library("crayon", lib.loc="C:/Users/unalu/Documents/R/win-library/3.5/library")
library("forecast", lib.loc="C:/Users/unalu/Documents/R/win-library/3.5/library")


#Define a function to delete NAs.There will be NAs in the retreived data from FROM
delete.na <- function(DF, n=0) {
  DF[rowSums(is.na(DF)) <= n,]
}


# Function that selects the optimum AR(p) and MA(q) parameters and the Integration (d).
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
# SYMBOL: First Component of the function is the symbol for the time series data that will be retreived from the database SOURCE
# SOURCE: Second Component of the function which is the data source (ex; FRED, YAHOO)
# testRatio: Third Component of the function which is the train set / test set ratio 
# infoCrea: Information criteria that will be used to choose optimum lags for the ARIMA model
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



