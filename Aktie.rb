require 'pry'
Pry.commands.alias_command 'n', 'next'
Pry.commands.alias_command 'c', 'continue'
Pry.commands.alias_command 's', 'step'

stockPrices = []
File.open('omxMontly.txt').each { |line| stockPrices << line }

def doCalculationsForPeriod

end

for measurePeriodInMonths in (12..250).step(12)
  bad = 0
  good = 0
  sellPctChangeSum = 0.0
  buyPctChangeSum = 0.0
  triesCnt = 1000
  for tries in 1..triesCnt
    gainMax = 0
    stocksValueMax = 0
    cashMax = 0
    totalValueMax = 0
    sellPctChangeMax = 0
    buyPctChangeMax = 0
    tradeCntMax = 0
    noTradeGainMax = 0

    startIndex = rand(stockPrices.length - measurePeriodInMonths)
    endIndex = startIndex + measurePeriodInMonths
    # startIndex = 0
    # endIndex = stockPrices.length

    for buyPctChange in (-3.8..-3.8).step(0.1)
      for sellPctChange in (-4.6..-4.6).step(0.1)
        for buyTradePct in (100.0..100.0).step(25)
          for sellTradePct in (100.0..100.0).step(25)
            startSeed = 200000.0
            cashAdded = 0
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
            # stockPrices.each {|stockPrice|

            for priceIndex in startIndex..endIndex
              stockPrice = stockPrices[priceIndex]
              currentStockPrice = stockPrice.to_i
              next if currentStockPrice == 0

              cash += cashAdded
              totalCashAdded += cashAdded

              if first
                startPrice = currentStockPrice
                lastStockPrice = stockPrice.to_i
                stocksCnt = (startSeed - cash) / stockPrice.to_i
                # cash = startSeed
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

              if tradeAction != 'NoAction'
                #     printf "TraceAction:%-20s - total:%-20d  stocksValue:%-20d, %-20d, %-20d\n", tradeAction, totalValue, stocksValue, lastStockPrice, currentStockPrice
              end
              # }
            end


            noTradeGain = endPrice / (startPrice * 1.0)

            if gain > gainMax
              gainMax = gain
              stocksValueMax = stocksValue
              cashMax = cash
              buyPctChangeMax = buyPctChange
              sellPctChangeMax = sellPctChange
              totalValueMax = totalValue
              sellTradePctMax = sellTradePct
              buyTradePctMax  = buyTradePct
              tradeCntMax = tradeCnt
              # binding.pry
              # puts "pctChange:#{pctChangeMax} - sellTradePct:#{sellTradePctMax} - buyTradePct:#{buyTradePctMax} - cash:#{cashMax} - stockValue:#{stocksValueMax} - total:#{totalValueMax} - gain:#{gainMax}"

              #   printf "sellPctChange:%-10f buyPctChange:%-10f sellTradePct:%-3d buyTradePct:%-3d tradeCnt:%-5d total:%-5d gain:%-10f pct:%-10f noTradeGain:%-10f\n",
              #   sellPctChange, buyPctChange, sellTradePct, buyTradePct, tradeCnt, totalValue,
              #   gain, ((gain**(1.0/(stockPrices.length/12))-1)*100.0), noTradeGain

            end
            if noTradeGain > noTradeGainMax
              noTradeGainMax = noTradeGain
            end
            next unless false

            printf '****' if noTradeGain > gain

            printf "sellPctChange:%-10f buyPctChange:%-10f sellTradePct:%-3d buyTradePct:%-3d tradeCnt:%-5d total:%-5d gain:%-10f pct:%-10f noTradeGain:%-10f\n",
                   sellPctChange, buyPctChange, sellTradePct, buyTradePct, tradeCnt, totalValue,
                   gain, ((gain**(1.0 / (stockPrices.length / 12)) - 1) * 100.0), noTradeGainMax
        end
      end
      end

    end

    sellPctChangeSum += sellPctChangeMax
    buyPctChangeSum += buyPctChangeMax

    if noTradeGain > gain
      bad += 1
    else
      good += 1
    end

    next unless false
    puts '---------------------------------------------------------------------------------------'
    printf "sellPctChange:%-10f buyPctChange:%-10f sellTradePct:%-3d buyTradePct:%-3d tradeCnt:%-5d total:%-5d gain:%-10f pct:%-10f noTradeGain:%-10f\n",
           sellPctChangeMax, buyPctChangeMax, sellTradePctMax, buyTradePctMax, tradeCntMax, totalValueMax,
           gainMax, ((gainMax**(1.0 / ((endIndex - startIndex) / 12)) - 1) * 100.0), noTradeGainMax

    years = (endIndex - startIndex) / 12
    startYear = 1991 + startIndex / 12
    endYear = 1991 + endIndex / 12
    puts "startIndex:#{startIndex}, endIndex:#{endIndex} years:#{startYear}-#{endYear}"
  end

  bestSellPctChange = sellPctChangeSum/triesCnt
  bestBuyPctChange = buyPctChangeSum/triesCnt

  printf "measurePeriodInMonths:%-5d Bad:%-5d Good:%-5d gainMax:%-5f noTradeGain:%-5f bestSellPctChange:%-5f bestBuyPctChange:%-5f\n",
    measurePeriodInMonths, bad, good, gainMax, noTradeGainMax, bestSellPctChange, bestBuyPctChange

end
