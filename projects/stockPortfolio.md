## Stock Price Forecasting and Portfolio Value at Risk (VaR)

**Description:** This project combines two key components: Stock price forecasting using Geometric Brownian Motion (GBM) and Monte Carlo Simulation for portfolio management. By integrating these techniques, the project aims to provide a method to forecast individual stock returns and measure the value at risk (VaR) within the context of a diversified portfolio.

### Geometric Brownian Motion (GBM)
GBM is a widely used stochastic process to model the evolution of stock prices over time. By simulating multiple possible future scenarios, we estimate the potential range of outcomes for the stock's price.

- **Explicit expression:** 

  $$ S_t = S_0 \exp \left( (\mu - \frac{\sigma^2}{2}) t + \sigma W_t \right) $$

  Where:

  $$
  \begin{align*}
  S_t & : \text{Stock price at time \( t \)} \\
  S_0 & : \text{Initial stock price (at time \( t = 0 \))} \\
  \mu & : \text{Drift coefficient} \\
  \sigma & : \text{Volatility} \\
  W_t & : \text{Wiener process or Brownian motion} \\
  \end{align*}
  $$

Drift ($\mu$) serves as an indicator of the average rate of return of the stock over time, influencing the long-term trend of simulated trajectories. Volatility ($\sigma$), on the other hand, measures the degree of price fluctuation around this average return, directly impacting the magnitude of short-term fluctuations in trajectories. The Wiener process ($W_t$) introduces randomness or unpredictability into the trajectories, representing the stochastic nature of stock price movements.



In [Python](https://github.com/jaredec/jaredec.github.io/blob/master/projects/stocks/stockPriceForecast.py){:target="_blank"}, we set up these parameters using the latest stock data, and by applying the GBM formula, we can generate multiple simulated trajectories of future stock prices. This technique, known as Monte Carlo Simulation, enables us to simulate various potential outcomes for a stock.
<img src="images/gbm_mc_sims.png?raw=true"/>

Another way to visualize these results is with a histogram at the final price at each simulation: 
<img src="images/gbm_hist.png?raw=true"/>


### Application in Portfolio Management
In this section, we extend the application of Monte Carlo Simulation to manage a portfolio of stocks and evaluate the associated risks. Unlike the previous Monte Carlo Simulation for individual stock price forecasting, here, we focus on simulating the performance of an entire portfolio. 

The key difference here is that we are now simulating a system with multiple correlated stocks. In our new [Python code](https://github.com/jaredec/jaredec.github.io/blob/master/projects/stocks/MC.py){:target="_blank"}, we generate a covariance matrix based on returns and utilize a technique known as Cholesky Decomposition.
This matrix will help us understand how individual stock returns relate to each other within a portfolio. 

By applying the Cholesky Decomposition method, we simplify the covariance matrix, making it easier to work with. This simplification enables us to simulate returns by multiplying it with a random vector of independent standard normally distributed variables.

- Consider this portfolio of stocks with an initial value of $10,000:

  1. Apple Inc. (AAPL) 
  2. Johnson & Johnson (JNJ) 
  3. Amazon.com Inc. (AMZN) 
  4. Microsoft Corporation (MSFT) 
  5. The Coca-Cola Company (KO) 
  6. Tesla, Inc. (TSLA) 
  7. Visa Inc. (V) 
  8. Alphabet Inc. (GOOG) 
  9. Procter & Gamble Company (PG) 
  10. JPMorgan Chase & Co. (JPM) 

<img src="images/portfolio_simulation.png?raw=true"/>

### Value at Risk and Expected Portfolio Return
In risk management, Value at Risk (VaR) is a key metric used to quantify the potential loss in value of a portfolio over a specified time horizon under normal market conditions at a given confidence level. It provides investors with an estimate of the maximum loss they might incur within a certain probability.

Following the Monte Carlo Simulation for the portfolio, we analyze the distribution of simulated portfolio values to compute VaR. Additionally, we determine the expected portfolio return.

In this scenario, we set the confidence level, known as alpha, to 5%, corresponding to a 95% confidence interval that our portfolio's value will remain above a specified threshold.

- **Value at Risk (VaR):** In our analysis, we found a VaR of $1,477.96, indicating that there is a 5% chance of experiencing a loss greater than this amount over the specified time horizon.
- **Expected Portfolio Return:** The expected portfolio return provides an estimate of the average return investors can anticipate based on the simulated outcomes. In our analysis, the expected return was found to be $2,690.67, or 26.91%.

<img src="images/portfolio_hist.png?raw=true"/>

> Data from Yahoo Finance (yfinance library in Python).
