import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import datetime as dt
import yfinance as yf

# Import Data
def get_data(stocks, start, end):
    stockData = yf.download(stocks, start=start, end=end)['Adj Close']
    returns = stockData.pct_change()
    meanReturns = returns.mean() 
    covMatrix = returns.cov()
    return meanReturns, covMatrix

stocklist = ['AAPL', 'JNJ', 'AMZN', 'MSFT', 'KO', 'TSLA', 'V', 'GOOG', 'PG', 'JPM']
stocks = ' '.join(stocklist)
n_years = 5
endDate = dt.datetime.now()
startDate = endDate - dt.timedelta(days= 365 * n_years)

meanReturns, covMatrix = get_data(stocks, startDate, endDate)

# Random weights
## weights = np.random.random(len(meanReturns))
## weights /= np.sum(weights)

# Equal weights
num_stocks = len(meanReturns)
weights = np.full(num_stocks, 1/num_stocks)


print(meanReturns * 100)

# Monte Carlo Method
mc_sims = 10000 # number of simulations
T = 252 # timeframe in days (252 trading days in a year)

meanM = np.full(shape = (T, len(weights)), fill_value= meanReturns)
meanM = meanM.T

portfolio_sims = np.full(shape=(T, mc_sims), fill_value = 0.0)

initialPortfolio = 10000

for m in range(0, mc_sims):
    # MC loops
    Z = np.random.normal(size = (T, len(weights)))
    L = np.linalg.cholesky(covMatrix)
    dailyReturns = meanM + np.inner(L, Z)
    portfolio_sims[:, m] = np.cumprod(np.inner(weights, dailyReturns.T) + 1 ) * initialPortfolio

# Returns from MC sims at alpha
def mcVaR(returns, alpha):
    if isinstance(returns, pd.Series):
        return np.percentile(returns, alpha)
    else:
        raise TypeError("Expected a pandas data series.")
    
alpha = 5

portfolioResults = pd.Series(portfolio_sims[-1,:]) # only interested in end price in sims

# Value at risk
VaR = initialPortfolio - mcVaR(portfolioResults, alpha=5)

# Expected gains
absoluteReturn = portfolioResults.mean()
expectedReturn = ((absoluteReturn - initialPortfolio) / initialPortfolio) * 100


# Value at Risk
print(f'Value at Risk: ${VaR:,.2f}')

# Expected Final Portfolio Value
print(f'Expected Final Portfolio Value: ${absoluteReturn:,.2f}')

# Expected Return
print(f'Expected Return: {expectedReturn:,.2f}%')

plt.plot(portfolio_sims[:,0:100])
plt.ylabel('Portfolio Value ($)')
plt.xlabel('Days')
plt.title('MC Simulation of stock portfolio')
plt.savefig('portfolio_simulation.png')

plt.figure()
plt.hist(portfolioResults, bins=100)
plt.xlabel('Portfolio Value ($)')
plt.ylabel('Frequency')
plt.axvline(x=initialPortfolio, color='b', linestyle='--', label='Initial Portfolio Value')
plt.axvline(x=absoluteReturn, color='black', linestyle='--', label='Expected Portfolio Value')
plt.axvline(x=mcVaR(portfolioResults, alpha), color='r', linestyle='--', label=f'Bottom {alpha}% of Simulations')
plt.axvspan(initialPortfolio, mcVaR(portfolioResults, alpha), alpha=0.2, color='red', label = 'Value at Risk')
plt.legend()
plt.title('Histogram of Final Portfolio Value')
plt.savefig('portfolio_hist.png')
