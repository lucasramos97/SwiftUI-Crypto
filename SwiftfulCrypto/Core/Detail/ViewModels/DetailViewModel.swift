//
//  DetailViewModel.swift
//  SwiftfulCrypto
//
//  Created by Lucas Ramos on 09/10/22.
//

import Foundation
import Combine

class DetailViewModel: ObservableObject {
    
    @Published var coin: CoinModel
    @Published var overviewStatistics: [StatisticModel] = []
    @Published var additionalStatistics: [StatisticModel] = []
    @Published var coinDescription: String? = nil
    @Published var websiteURL: String? = nil
    @Published var redditURL: String? = nil
    
    private let coinDetailDataService: CoinDetailDataService
    private var cancellables = Set<AnyCancellable>()
    
    init(coin: CoinModel) {
        self.coin = coin
        coinDetailDataService = CoinDetailDataService(coin: coin)
        addSubscribers()
    }
    
    private func addSubscribers() {
        coinDetailDataService.$coinDetails
            .combineLatest($coin)
            .map(mapDataToStatistics)
            .sink { [weak self] (returnedOverviewStatistics, returnedAdditionalStatistics) in
                self?.overviewStatistics = returnedOverviewStatistics
                self?.additionalStatistics = returnedAdditionalStatistics
            }
            .store(in: &cancellables)
        
        coinDetailDataService.$coinDetails
            .sink { [weak self] returnedCoinDetails in
                self?.coinDescription = returnedCoinDetails?.readableDescription
                self?.websiteURL = returnedCoinDetails?.links?.homepage?.first
                self?.redditURL = returnedCoinDetails?.links?.subredditURL
            }
            .store(in: &cancellables)
    }
    
    private func mapDataToStatistics(details: CoinDetailModel?, coin: CoinModel) -> ([StatisticModel], [StatisticModel]) {
        let overviewStatistics = createOverviewArray(coin: coin)
        let additionalStatistics = createAdditionalArray(details: details, coin: coin)
        
        return (overviewStatistics, additionalStatistics)
    }
    
    private func createOverviewArray(coin: CoinModel) -> [StatisticModel] {
        let price = coin.currentPrice.asCurrencyWith6Decimals()
        let priceChange = coin.priceChangePercentage24H
        let marketCap = "$" + (coin.marketCap?.formattedWithAbbreviations() ?? "")
        let marketCapChange = coin.marketCapChangePercentage24H
        let rank = "\(coin.rank)"
        let volume = "$" + (coin.totalVolume?.formattedWithAbbreviations() ?? "")
        
        return [
            StatisticModel(title: "Current Price", value: price, percentageChange: priceChange),
            StatisticModel(title: "Market Capitalization", value: marketCap, percentageChange: marketCapChange),
            StatisticModel(title: "Rank", value: rank),
            StatisticModel(title: "Volume", value: volume)
        ]
    }
    
    private func createAdditionalArray(details: CoinDetailModel?, coin: CoinModel) -> [StatisticModel] {
        let high = coin.high24H?.asCurrencyWith6Decimals() ?? "n/a"
        let low = coin.low24H?.asCurrencyWith6Decimals() ?? "n/a"
        let priceChange = coin.priceChange24H?.asCurrencyWith6Decimals() ?? "n/a"
        let pricePercentChange = coin.priceChangePercentage24H
        let marketCapChange = "$" + (coin.marketCapChange24H?.formattedWithAbbreviations() ?? "")
        let marketCapPercentChange = coin.marketCapChangePercentage24H
        let blockTime = details?.blockTimeInMinutes ?? 0
        let blockTimeString = blockTime == 0 ? "n/a" : "\(blockTime)"
        let hashing = details?.hashingAlgorithm ?? "n/a"
        
        return [
            StatisticModel(title: "24h High", value: high),
            StatisticModel(title: "24h Low", value: low),
            StatisticModel(title: "24h Price Change", value: priceChange, percentageChange: pricePercentChange),
            StatisticModel(title: "24 Market Cap Change", value: marketCapChange, percentageChange: marketCapPercentChange),
            StatisticModel(title: "Block Time", value: blockTimeString),
            StatisticModel(title: "Hashing Algorithm", value: hashing)
        ]
    }
}
