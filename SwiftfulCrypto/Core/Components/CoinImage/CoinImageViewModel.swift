//
//  CoinImageViewModel.swift
//  SwiftfulCrypto
//
//  Created by Lucas Ramos on 05/10/22.
//

import Foundation
import SwiftUI
import Combine

class CoinImageViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var isLoading = false
    
    private let coinImageService: CoinImageService
    private var cancellables = Set<AnyCancellable>()
    
    init(coin: CoinModel) {
        coinImageService = CoinImageService(coin: coin)
        addSubscribers()
        isLoading = true
    }
    
    private func addSubscribers() {
        coinImageService.$image
            .sink(receiveCompletion: { [weak self] _ in
                self?.isLoading = false
            }, receiveValue: { [weak self] returnedImage in
                self?.image = returnedImage
            })
            .store(in: &cancellables)
    }
}
