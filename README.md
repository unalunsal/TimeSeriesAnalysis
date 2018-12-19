# Time Series Analysis using R 

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




