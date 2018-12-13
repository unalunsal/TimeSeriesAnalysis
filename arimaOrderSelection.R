#install.packages("stringi", lib="C:/Users/l1uxu01/AppData/Local/Packages/r_packages")



library("DBI", lib.loc = "C:/Users/l1uxu01/AppData/Local/Packages/r_packages")

library("dplyr", lib.loc = "C:/Users/l1uxu01/AppData/Local/Packages/r_packages")

library("implyr", lib.loc = "C:/Users/l1uxu01/AppData/Local/Packages/r_packages")

library("odbc", lib.loc = "C:/Users/l1uxu01/AppData/Local/Packages/r_packages")

library("zoo", lib.loc = "C:/Users/l1uxu01/AppData/Local/Packages/r_packages")

library("TTR", lib.loc = "C:/Users/l1uxu01/AppData/Local/Packages/r_packages")

library("xts", lib.loc = "C:/Users/l1uxu01/AppData/Local/Packages/r_packages")

library("quantmod", lib.loc = "C:/Users/l1uxu01/AppData/Local/Packages/r_packages")

library("parallel", lib.loc = "C:/Users/l1uxu01/AppData/Local/Packages/r_packages")

library("rugarch", lib.loc = "C:/Users/l1uxu01/AppData/Local/Packages/r_packages")

library("datasets", lib.loc = "C:/Users/l1uxu01/AppData/Local/Packages/r_packages")

library("forecast", lib.loc = "C:/Users/l1uxu01/AppData/Local/Packages/r_packages")





# get U.S./Euro Foreign Exchange Rate (DEXUSEU)          from FRED

getSymbols('DEXUSEU',src='FRED')



#Define a function to delete NAs

delete.na <- function(DF, n=0) {
  
  DF[rowSums(is.na(DF)) <= n,]
  
}



dexuseu <- delete.na(DEXUSEU)



#Split train - test set. Training set will be used to make the order selection for the ARMA(p,q) model.

dexuseu.train <- dexuseu[0:round(length(dexuseu) / 2)]

dexuseu.test <- dexuseu[(round(length(dexuseu) / 2) + 1) : length(dexuseu)]



# save train and test sets as vectors

dexuseu.train <- as.vector(dexuseu.train)

dexuseu.test <- as.vector(dexuseu.test)





# look at the first order differenced data 

ts.plot(diff(dexuseu.train), main = "USD/EUR Diff")

# There is clear heteroskedasticity in the data since the variance is not constant through time.

# Mean of the series seems to be constant with some small variation through time. I will assume that the first order differenced series is stationary.





# Let`s find the best ARIMA(p,q) order on the training set based on two different information criterias; AIC and BIC

# For both information criteria, I will also assume that p < 7 and q < 7



final.aic = Inf

final.bic = Inf

final.order.aic = c(0,0)

final.order.bic = c(0,0)



for (p in 0:6) for (q in 0:6) {
  
  mod.ic = arima(dexuseu.train,order = c(p,1,q), method='ML')
  
  current.aic = AIC(mod.ic)
  
  current.bic = BIC(mod.ic)
  
  print(paste("ARMA(p,q) order: ",p,q,"BIC : ",current.bic))
  
  print(paste("ARMA(p,q) order: ",p,q,"AIC : ",current.aic))
  
  
  
  if (current.aic < final.aic) {
    
    final.aic = current.aic
    
    final.order.aic = c(p, q)
    
    fit.aic = mod.ic
    
  }
  
  if (current.bic < final.bic) {
    
    final.bic = current.bic
    
    final.order.bic = c(p, q)
    
    fit.bic = mod.ic
    
  }
  
}



print(paste("Based on the AIC, optimum ARMA(p,q) order: ", final.order.aic[1], final.order.aic[2]))

print(paste("Based on the BIC, optimum ARMA(p,q) order: ", final.order.bic[1], final.order.bic[2]))



# As it can be seen that the model selected based on the Bayesian Information Criteria,

# has lower autoregressive and moving average orders than the model selected based on the Akaike Information Criteria.





# Now let`s compare both models based on their out of sample forecasting accuracy, specifically based on the Out of Sample Root Mean Squared Error (RMSE) levels.

mod.aic = arima(dexuseu.train,order = c(final.order.aic[1],1,final.order.aic[2]), method='ML')

mod.bic = arima(dexuseu.train,order = c(final.order.bic[1],1,final.order.bic[2]), method='ML')





mod.aic.fore <- forecast(mod.aic, h = length(dexuseu.test))$mean

mod.bic.fore <- forecast(mod.bic, h = length(dexuseu.test))$mean





mod.aic.rmse <- sqrt(mean((mod.aic.fore - dexuseu.test)^2))

mod.bic.rmse <- sqrt(mean((mod.bic.fore - dexuseu.test)^2))



if (mod.aic.rmse < mod.bic.rmse){
  
  print(paste("ARMA(", final.order.aic[1],",",final.order.aic[2],")" , "selected based on AIC has lower out of sample RMSE than the model ARMA(",final.order.bic[1],",",final.order.bic[2],")", "selected based on the BIC" ))
  
} else if (mod.aic.rmse > mod.bic.rmse){
  
  print(paste("ARMA(", final.order.bic[1],",",final.order.bic[2],")" , "selected based on BIC has lower out of sample RMSE than the model ARMA(",final.order.aic[1],",",final.order.aic[2],")", "selected based on the AIC" ))
  
} else {print(paste("ARMA(", final.order.bic[1],",",final.order.bic[2],")" , "selected based on BIC has the same out of sample RMSE with the model ARMA(",final.order.aic[1],",",final.order.aic[2],")", "selected based on the AIC" ))
  
}





# This note is good!! especially the final pages: https://faculty.washington.edu/ezivot/econ582/econ512forecastevaluation.pdf

