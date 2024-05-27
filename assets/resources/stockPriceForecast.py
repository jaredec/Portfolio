import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import datetime as dt
import yfinance as yf

# Download Stock Data
stockName = 'SPY'
n_years = 5
endDate = dt.datetime.now()
startDate = endDate - dt.timedelta(days = n_years * 365)

stockPrices = yf.download(stockName, startDate, endDate)['Adj Close']
logReturns = np.log(stockPrices/ stockPrices.shift(1)).dropna()

rollingWindowDays = 21
volatility = logReturns.rolling(rollingWindowDays).std() * np.sqrt(252)

# Geometric Brownian Motion
s0 = stockPrices.iloc[-1]
r = 0.05
vol = volatility.iloc[-1]
T = 1

n_timeIntervals = 252 # 1 year in trading daya
n_sims = 10000

deltaT = T / n_timeIntervals
sFwd = np.zeros((n_timeIntervals + 1, n_sims))
sFwd[0] = s0

for t in range(1, n_timeIntervals + 1):
    sFwd[t] = sFwd[t - 1] * np.exp((r - 0.5 * vol**2)* deltaT + vol * np.sqrt(deltaT) * np.random.standard_normal(n_sims))

deltaStockPrice = (sFwd[-1] - s0).mean() / s0
deltaStockPrice_asPercent = f'{deltaStockPrice:.2%}'
print('Stock Price Forecast:', deltaStockPrice_asPercent)

plt.figure()
plt.plot(sFwd[:,0:100])
plt.xlabel('Days $(t)$')
plt.ylabel("Stock Price $(S_t)$")
plt.title('Stock Price Evolution of SPY (S&P 500)')
plt.savefig('gbm_mc_sims.png')

averageStockPrice = np.mean(sFwd[-1])

# Plot histogram of final stock prices
plt.figure()
plt.hist(sFwd[-1], bins=100)
plt.axvline(x=s0, color='blue', linestyle='--', label='Initial Stock Price $(S_0)$')
plt.axvline(x=averageStockPrice, color='black', linestyle='--', label='Average Final Stock Price')
plt.xlabel('Final Stock Price $(S_t)$')
plt.ylabel('Frequency')
plt.title('Histogram of Final Stock Prices')
plt.legend()
plt.savefig('gbm_hist.png')