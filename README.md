<center><strong>blockframe</strong>
 <p><i>Crypto charting over the block-generation period.</i></p></center>

 Constructing a blockFrame chart as a graphical representation of a series of crypto asset price movements over block heights, - instead of time - where the basic graphical frame is one block, and the multipliers n blocks used for diverse graphical chart frames. blockFrame instead of timeframe charting, for a universe - Blockchain - where objective time doesn't exist, and succession materialize only by mining new blocks. 

 Conventional charts like candlestick, bar, line charts print a new units (new candle, bar or point) every hour, day, week or another time-frame interval the observer chooses as his period setting, on the other hand, blockFrames chart plots crypto asset price movements without taking into consideration the passage of time in the static constant time-frame; but over dynamic block-generation period of time, the time to mine a new block. You might set 1 block interval, which mean that the blockframe chart will show you a new candle or bar on the chart every time new block was minted.

# Paper
[blockFrame Original Paper](https://ssrn.com/abstract=3064115 )

# Chart<sup>BETA</sup>
[Open Chart in separate window](http://data.blockframe.xyz/?blocks=504) :: [w/ highstock Chart](http://data.blockframe.xyz/highstock.html) 

<iframe src="http://data.blockframe.xyz/?blocks=504" style="height:330px;width:100%;border:none;" scrolling="no"></iframe>


[blockFrame data endpoint](http://data.blockframe.xyz:8000/last/100) :: [Export as CSV](http://data.blockframe.xyz:8000/csv/prices/100) 

# Why
 **Native blockchain experiance**
> No matter how much time is passed minutes or hours, succession materialize only by mining new blocks, and visulizing the data not just price data, but volume, and transactions, hashrate, blocksize only possible with highest accurecy over block numbers.

 **Data Visulization for Crypto**
> Choose settings depending on the criteria you value the most

 **The 'Go to..' block height**
> Cryptocurrencies events happen on specific block height, having blockFrame chart would allow us to jump 'Go to..' specific  block number and see on the chart what happen then, the block where the fork happend or halving or difficulty adjusment etc.


# Roadmap
1. blockFrame - Alpha // Current 
 - [x]  basic implementation of blockFrame concept on bitcoin using public API for both block hight and price
 - [x]  Connect Highcharts Interactive JavaScript Candlesticks charts 

2. blockFrame V02
 - 
 - [ ]  High-quality instant price information of current Bitcoin rate from bitcoinaverage or others
 - [ ]  store locally historical price data of BTC with smallest incremental time-frame possible (ideally tick data) for last years
 - [ ]  redundant matching mechanism to calculate between the time-stamps of two blocks the Open, highest high, lowest low, and close and calculate the volume
 - [ ]  test alternative charting libraries (ex. Chart.js, Highcharts, C3, NVD3, Plotly.js, Chartist, Victory or Tradingview)
 - [ ]  Matching Mechanism: re-define the matching mechanism as 3 tables structure
    - A. block heights & time-stamp
    - B. OHLCV & time-stamp
    - C. block heights & OHLCV 
    Both A. & B. built from API, matching mechanism is to generate C. (new block would triger new entry on C.)

3. blockFrame V03
 - [ ]  block height to be obtained locally (full node) instead of current blockchain.info API
 - [ ]  locally storing additional relevant information: Number of Transactions, difficulty, hashrate, blocksize etc
 - [ ]  mapping the additional informations to block hight on the chart

4. blockFrame V04 :: **Reasonably usable version**
 * Implement blockframe with TradingView (ability to use the already builtin technical analysis functionalities)
 * Add Ethereum 
 * add events as optional view comment on specific block height (block height of major Fork, halfling, difficulty adjustment, upgrade etc)
5. blockFrame V05 :: blockframe for all major 20 cryptocurrencies
6. blockFrame V06 :: provide developer API for historical blockframe data of all major cryptocurrencies

# Contribute
 * Fork [blockFrame](https://github.com/drhus/blockframe) Github repository: Fix a bug or implement a new feature.
 * Report [issues](https://github.com/drhus/blockframe/issues) and/or make suggestions
 * Donate: to developmnet fund to accelerate the efforts so a **reasonably usable version** became soon available :) 
   * BTC: `13TiMKr4WaSg26hj3bEyzL3JCEURGcgJvi`   [QR](https://chart.googleapis.com/chart?cht=qr&chs=500x500&choe=UTF-8&chld=H&chl=13TiMKr4WaSg26hj3bEyzL3JCEURGcgJvi)
   * ETH: 
  
  
<br>
<a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/88x31.png" /></a>

