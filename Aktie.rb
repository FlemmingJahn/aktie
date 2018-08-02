# Language: Ruby, Level: Level 3
require 'pry'
Pry.commands.alias_command 'n', 'next'
Pry.commands.alias_command 'c', 'continue'
Pry.commands.alias_command 's', 'step'

def getStockPrices(stockName)
  if defined?(stockPrices).nil?
    stockPrices = []
    File.open(stockName).each { |line| stockPrices << line }
  end
  stockPrices
end
$printTrade = false

def doCalculation(buyPctChange, sellPctChange, buyTradePct, sellTradePct, measurePeriodInMonths, stockName)
  stocksValueMax = 0
  cashMax = 0
  totalValueMax = 0
  sellPctChangeMax = 0
  buyPctChangeMax = 0
  tradeCntMax = 0

  startSeed = 200_000.0
  cashAdded = 0 #10000
  cash = 0.0
  stocksCnt = 0
  first = true
  lastStockPrice = 0
  stocksValue = 0
  totalValue  = 0
  gain = 0
  lastStockPrice = 0
  totalCashAdded = 0
  startPrice = 1
  endPrice = 1
  tradeCnt = 0

  stockPrices = getStockPrices(stockName)
  if measurePeriodInMonths > stockPrices.length
    startIndex = 0
  else
    startIndex = rand(stockPrices.length - measurePeriodInMonths)
  end
  endIndex = startIndex + measurePeriodInMonths

  for priceIndex in (startIndex..endIndex)
    stockPrice = stockPrices[priceIndex]
    currentStockPrice = stockPrice.to_i
    next if currentStockPrice == 0
    cash += cashAdded
    totalCashAdded += cashAdded

    if first
      startPrice = currentStockPrice
      lastStockPrice = stockPrice.to_i
      stocksCnt = (startSeed - cash) / stockPrice.to_i
      #cash = startSeed
      first = false
    end
    endPrice = currentStockPrice
    stocksValue = stocksCnt * stockPrice.to_i
    totalValue = cash + stocksValue

    cashPct = cash / totalValue * 100
    # if cashPct >= 0
    tradeAction = 'NoAction'

    # raising
    if lastStockPrice * (1 - buyPctChange / 100.0) < currentStockPrice
      #  if lastStockPrice * (1 + sellPctChange / 100.0) > currentStockPrice
      #  buyValue =  cash - totalValue/2
      buyValue = cash * buyTradePct / 100
      buyValue = 0 if buyValue < 0
      stocksCnt += buyValue / stockPrice.to_i
      lastStockPrice = currentStockPrice
      cash -= buyValue

      if buyValue > 0
        tradeCnt += 1
        tradeAction = 'Buy'
      end

    # falling
    elsif lastStockPrice * (1 + sellPctChange / 100.0) > currentStockPrice
      # elsif lastStockPrice * (1 - buyPctChange / 100.0) < currentStockPrice
      #  sellValue =  stocksValue - totalValue/2
      sellValue = stocksValue * (sellTradePct / 100)
      sellValue = 0 if sellValue < 0
      stocksCnt -= sellValue / stockPrice.to_i
      if sellValue > 0
        tradeCnt += 1
        tradeAction = 'Sell'
      end
      cash += sellValue
      #  binding.pry
      lastStockPrice = currentStockPrice
     end
    lastStockPrice = currentStockPrice
    stocksValue = stocksCnt * stockPrice.to_i
    totalValue = cash + stocksValue
    gain = totalValue / (startSeed + totalCashAdded)

    if tradeAction != 'NoAction' && $printTrade
      printf "Index:%-5d, TraceAction:%-10s total:%-10d stocksValue:%-10d lastStockPrice:%-10d currentStockPrice:%-10d\n", priceIndex, tradeAction, totalValue, stocksValue, lastStockPrice, currentStockPrice
    end
    # }
  end

  noTradeGain = endPrice / (startPrice * 1.0)
  [noTradeGain, gain, tradeAction]
end

def doCalculations(measurePeriodInMonths, stockName)
  gainMax = 0
  noTradeGainMax = 0
  bestNoTradeGain = 0
  bestGain        = 0
  bestGood = 0
  bestBad = 0
  bestBuyPctChange = 0
  bestSellPctChange = 0
  bestBuyTradePct = 0
  bestSellTradePct = 0
  for sellPctChange in (-4.1..-4.1).step(0.3)
    for buyPctChange in (-4.1..-4.1).step(0.3 )
      for sellTradePct in (100.0..100.0).step(10)
        for buyTradePct in (100.0..100.0).step(10)

          bad = 0
          good = 0
          averageGain = 0
          averageNoTradeGain = 0
          triesCnt = 100
          for tries in 1..triesCnt
            noTradeGain, gain, tradeAction = doCalculation(buyPctChange, sellPctChange, buyTradePct, sellTradePct, measurePeriodInMonths, stockName)

            if gain > gainMax
              gainMax = gain
              #      stocksValueMax = stocksValue
              #    buyPctChangeMax = buyPctChange
              #    sellPctChangeMax = sellPctChange
              #    totalValueMax   = totalValue
              #      sellTradePctMax = sellTradePct
              #      buyTradePctMax  = buyTradePct
              #        tradeCntMax     = tradeCnt
              # puts "pctChange:#{pctChangeMax} - sellTradePct:#{sellTradePctMax} - buyTradePct:#{buyTradePctMax} - cash:#{cashMax} - stockValue:#{stocksValueMax} - total:#{totalValueMax} - gain:#{gainMax}"

              #   printf "sellPctChange:%-10f buyPctChange:%-10f sellTradePct:%-3d buyTradePct:%-3d tradeCnt:%-5d total:%-5d gain:%-10f pct:%-10f noTradeGain:%-10f\n",
              #   sellPctChange, buyPctChange, sellTradePct, buyTradePct, tradeCnt, totalValue,
              #   gain, ((gain**(1.0/(stockPrices.length/12))-1)*100.0), noTradeGain
            end

            noTradeGainMax = noTradeGain if noTradeGain > noTradeGainMax

            if noTradeGain > gain
              bad += 1
            else
              good += 1
            end

            averageGain += gain
            averageNoTradeGain += noTradeGain

          end
          averageGain /= triesCnt
          averageNoTradeGain /= triesCnt

          next unless averageGain > bestGain
          bestBad = bad
          bestGood = good
          bestGain = averageGain
          bestNoTradeGain = averageNoTradeGain
          bestSellPctChange = sellPctChange
          bestBuyPctChange = buyPctChange
          bestSellTradePct = sellTradePct
          bestBuyTradePct = buyTradePct

            #    if noTradeGainMax > bestNoTradeGain
            #        bestNoTradeGain = noTradeGainMax
            #      end

          end
            end
    end
  end

  if false
    puts '---------------------------------------------------------------------------------------'
    printf "sellPctChange:%-10f buyPctChange:%-10f sellTradePct:%-3d buyTradePct:%-3d tradeCnt:%-5d total:%-5d gain:%-10f pct:%-10f noTradeGain:%-10f\n",
           sellPctChangeMax, buyPctChangeMax, sellTradePctMax, buyTradePctMax, tradeCntMax, totalValueMax,
           gainMax, ((gainMax**(1.0 / ((endIndex - startIndex) / 12)) - 1) * 100.0), noTradeGainMax

    years = (endIndex - startIndex) / 12
    startYear = 1991 + startIndex / 12
    endYear = 1991 + endIndex / 12
    puts "startIndex:#{startIndex}, endIndex:#{endIndex} years:#{startYear}-#{endYear}"
end
  [bestBad, bestGood, bestGain, bestNoTradeGain, bestSellPctChange, bestBuyPctChange, bestSellTradePct, bestBuyTradePct, tradeAction]
end

$gainSum = 0
$noTradeGainSum = 0
def doCalculationsForPeriod(measurePeriodInMonths, stockName)
  bad = 0
  good = 0
  gainMax = 0
  noTradeGainMax = 0

  #  for tries in 1..1000
  bad, good, gainMax, noTradeGainMax, bestSellPctChange, bestBuyPctChange, bestSellTradePct, bestBuyTradePct, tradeAction = doCalculations(measurePeriodInMonths, stockName)
  #  end

#  printf "period:%-3d Bad:%-3d Good:%-3d gainMax:%-5f noTradeGain:%-5f SellPct:%-5f BuyPcte:%-5f SellTradePct:%-5d BuyTradePct:%-5d, lastTraceAction:%-5s\n",
#         measurePeriodInMonths, bad, good, gainMax, noTradeGainMax, bestSellPctChange, bestBuyPctChange, bestSellTradePct, bestBuyTradePct, tradeAction
  printf "period:%-3d Bad:%-3d Good:%-3d gainMax:%-5f noTradeGain:%-5f lastTraceAction:%-5s\n",
                  measurePeriodInMonths, bad, good, gainMax, noTradeGainMax, tradeAction

  $gainSum += gainMax
  $noTradeGainSum += noTradeGainMax
end

if !$printTrade
  stocks = ["maersk.txt", "carl-b.txt", "chr.txt", "danske.txt", "fls.txt", "iss.txt", "jysk.txt", "NZYM-B.txt"]
  stocks.each { |stockName|
    puts ("********************** #{stockName} ******************************")
    for measurePeriodInMonths in (240..240).step(48)
      doCalculationsForPeriod(measurePeriodInMonths, stockName)
    end
  }
else
  noTradeGain, gain = doCalculation(-4.2, -7.1, 100, 100, 1000, "maersk.txt")
  printf 'noTradeGain:%-5f gain:%-5f', noTradeGain, gain

end
puts("gainSum:#{$gainSum} noTradeGainSum:#{$noTradeGainSum}")
