//
//  HomeViewModel.swift
//  SwiftfulCrypto
//
//  Created by Lucas Ramos on 02/10/22.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    @Published var statistics: [StatisticModel] = []
    @Published var searchText = ""
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    @Published var isLoading = false
    @Published var sortOption: SortOption = .holdings
    
    private let coinDataService = CoinDataService()
    private let marketDataService = MarketDataService()
    private let portfolioDataService = PortfolioDataService()
    private var cancellables = Set<AnyCancellable>()
    
    enum SortOption {
        case rank, rankReversed, holdings, holdingsReversed, price, priceReversed
    }
    
    init() {
        addSubscribers()
    }
    
    func updatePortfolio(coin: CoinModel, amount: Double) {
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }
    
    func reloadData() {
        isLoading = true
        marketDataService.getData()
        coinDataService.getCoins()
        HapticManager.notification(type: .success)
    }
    
    private func addSubscribers() {
        marketDataService.$marketData
            .combineLatest($portfolioCoins)
            .map(mapGlobalMarketData)
            .sink { [weak self] returnedStatistics in
                self?.statistics = returnedStatistics
                self?.isLoading = false
            }
            .store(in: &cancellables)
        $searchText
            .combineLatest(coinDataService.$allCoins, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterAndSortCoins)
            .sink { [weak self] returnedCoins in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellables)
        $allCoins
            .combineLatest(portfolioDataService.$savedEntities)
            .map(mapAllCoinsToPortfolioCoins)
            .sink { [weak self] returnedCoins in
                guard let self = self else { return }
                self.portfolioCoins = self.sortPortfolioCoinsIfNeeded(coins: returnedCoins)
            }
            .store(in: &cancellables)
    }
    
    private func mapGlobalMarketData(marketData: MarketDataModel?, portfolioCoins: [CoinModel]) -> [StatisticModel] {
        guard let marketData = marketData else {
            return []
        }
        
        var portfolioValue: Double = 0
        var percentageChange: Double? = nil
        if !portfolioCoins.isEmpty {
            portfolioValue = portfolioCoins.reduce(0) { $0 + $1.currentHoldingsValue }
            let previousValue = portfolioCoins.reduce(0) { (initial, coin) -> Double in
                let currentValue = coin.currentHoldingsValue
                let percentageChange = (coin.priceChangePercentage24H ?? 0) / 100
                
                return initial + currentValue / (1 + percentageChange)
            }
            percentageChange = (portfolioValue - previousValue) / previousValue
        }
        return [
            StatisticModel(title: "Market Cap", value: marketData.marketCap, percentageChange: marketData.marketCapChangePercentage24HUsd),
            StatisticModel(title: "24h Volume", value: marketData.volume),
            StatisticModel(title: "BTC Dominance", value: marketData.btcDominance),
            StatisticModel(title: "Portfolio Value", value: portfolioValue.asCurrencyWith2Decimals(), percentageChange: percentageChange)
        ]
    }
    
    private func filterCoins(text: String, coins: [CoinModel]) -> [CoinModel] {
        if text.isEmpty {
            return coins
        }
        
        let lowercasedText = text.lowercased()
        return coins.filter {
            $0.name.lowercased().contains(lowercasedText) ||
            $0.symbol.lowercased().contains(lowercasedText) ||
            $0.id.lowercased().contains(lowercasedText)
        }
    }
    
    private func filterAndSortCoins(text: String, coins: [CoinModel], sort: SortOption) -> [CoinModel] {
        let filterCoins = filterCoins(text: text, coins: coins)
        
        return filterCoins.sorted {
            switch sort {
            case .rank, .holdings:
                return $0.rank < $1.rank
            case .rankReversed, .holdingsReversed:
                return $0.rank > $1.rank
            case .price:
                return $0.currentPrice > $1.currentPrice
            case .priceReversed:
                return $0.currentPrice < $1.currentPrice
            }
        }
    }
    
    private func mapAllCoinsToPortfolioCoins(coins: [CoinModel], entities: [PortfolioEntity]) -> [CoinModel] {
        return coins.compactMap { coin in
            guard let entity = entities.first(where: { $0.coinID == coin.id }) else {
                return nil
            }
            
            return coin.updateCurrentHoldings(amount: entity.amount)
        }
    }
    
    private func sortPortfolioCoinsIfNeeded(coins: [CoinModel]) -> [CoinModel] {
        switch sortOption {
        case .holdings:
            return coins.sorted(by: { $0.currentHoldingsValue > $1.currentHoldingsValue })
        case .holdingsReversed:
            return coins.sorted(by: { $0.currentHoldingsValue < $1.currentHoldingsValue })
        default:
            return coins
        }
    }
}
