## Time Series Analysis using R 

I am assuming you already have some background in regression analysis / econometrics with some R programming experience. 

# ARIMA(p,d,q).AIC.R
This code forecasts recursive out of sample test set by using optimum ARIMA(p,d,q). 
It determines the optimum order for the ARIMA(p,d,q) by minimizing Akaike Information Creterion (AIC) from the traning set then it uses the model to make a  forecast for one period ahead. For each period up to time t, it determines the orders of the ARIMA(p,d,q) by minimizing the Akaike Information Creterion (AIC) and uses that model to forecast the observation at time t+1. This methodology is called recursive out of sample forecasting. 

All you need to do is changing the parameters in the recursive funtion call. 
As an example, 

recursive("DEXUSEU", "FRED", 0.5, AIC)

Calls the U.S. Dollar / Euro time series data from the FRED database which is publicly available data from the St. Louis FED. 
It seperates the data series into training and test sets at the ratio of 50% and by only using the training set, it determines the optimum ARIMA(p,d,q) order while minimizing Akaike Information Criterion (AIC). Once it finds out the optimum orders for the ARIMA(p,d,q), it forecasts the first observation in the test set.
Then it updates the traning and test sets by adding one observation to the traning set from test set. It recalculates the optimum ARIMA(p,d,q) order for the new traning set and then by using the new ARIMA(p,d,q), it forecasts the first observation in the new test set.
Algorithm will keep doing the same thing until there is no observation left to add from the test set to the training set. 

I also added constraint on the ARIMA(p,d,q) orders as p < 7, 0 < d < 3 and q < 7. 
These constraints on the ARIMA(p,d,q) orders can be changed from the function orderSelect(). 

Thanks. 

# ARIMA(p,d,q).BIC.R 
This algorithm is exact replica of the arima.aic.R. I added this just to show how easy it is to update the arima.aic.R parameters. 
In this code, I am following the same logic with arima.aic.R but this time, I am choosing the ARIMA(p,d,q) orders by minimizing the Bayesian Information Criterion (BIC). All I did was updating the parameters in the recursive function call. 

recursive("DEXUSEU", "FRED", 0.5, BIC)

Thanks. 

# ARMA(p,q)-GARCH(m,n).AIC.R 
For the model order selection, I am following the same logic with the ARIMA(p,d,q).AIC.R. However, I am introducing the GARCH(m,n) part for the variance of the innovations (error terms). It is common to have heteroskadasticity in time series data and therefore, it is a good practice to control for it. I added the GARCH(m,n) orders and the algorithm loops through different ARMA(p,q)-GARCH(m,n) orders and picks the one with the lowest AIC and makes prediction for the first observation in the test set. It will repeat the model selection through training set and forecast for the first observation on the test set until there is no observation left in the test set. Initial starting point for the model selection is the mid point of the population data. It can be changed with the third argument on the recursive() function call. 

recursive("DEXUSEU", "FRED", 0.5, 1) 

Thanks. 

# ARMA(p,q)-GARCH(m,n).BIC.R 
This code is the same as the ARMA(p,q)-GARCH(m,n).AIC.R. I added this just to show that how easy it is to update the ARMA(p,q)-GARCH(m,n).AIC.R. 
The only difference is in the recursive() function call and the optimum model orders for the ARMA(p,q)-GARCH(m,n) is determined by the Bayesian Information Criterion (BIC). Which is updated with the fourth element of the recursive function (2), it used to be 1 which represents the AIC. 

recursive("DEXUSEU", "FRED", 0.5, 2) 

Thanks. 

# ARMA(p,q)-EGARCH(m,n).AIC.R & ARMA(p,q)-EGARCH(m,n).BIC.R & ARMA(p,q)-IGARCH(m,n).AIC.R & ARMA(p,q)-IGARCH(m,n).BIC.R

