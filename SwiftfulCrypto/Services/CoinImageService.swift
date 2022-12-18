//
//  CoinImageService.swift
//  SwiftfulCrypto
//
//  Created by Lucas Ramos on 05/10/22.
//

import Foundation
import SwiftUI
import Combine

class CoinImageService {
    
    @Published var image: UIImage? = nil
    
    private let coin: CoinModel
    private var imageSubscription: AnyCancellable?
    private let localFileManager = LocalFileManager.instance
    private let folderName = "coin_images"
    private let imageName: String
    
    init(coin: CoinModel) {
        self.coin = coin
        imageName = coin.id
        getCoinImage()
    }
    
    private func getCoinImage() {
        if let savedImage = localFileManager.getImage(imageName: imageName, folderName: folderName) {
            image = savedImage
        } else {
            downloadCoinImage()
        }
    }
    
    private func downloadCoinImage() {
        guard let url = URL(string: coin.image) else { return }
        
        imageSubscription = NetworkingManger.download(url: url)
            .tryMap({ data -> UIImage? in
                return UIImage(data: data)
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManger.handleCompletion) { [weak self] returnedImage in
                guard let self = self, let downloadedImage = returnedImage else { return }
                self.image = downloadedImage
                self.localFileManager.saveImage(image: downloadedImage, imageName: self.imageName, folderName: self.folderName)
                self.imageSubscription?.cancel()
            }
    }
}
