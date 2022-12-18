//
//  PortfolioView.swift
//  SwiftfulCrypto
//
//  Created by Lucas Ramos on 08/10/22.
//

import SwiftUI

struct PortfolioView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var homeViewModel: HomeViewModel
    
    @State private var selectedCoin: CoinModel? = nil
    @State private var quantityText = ""
    @State private var showCheckmark = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SearchBarView(searchText: $homeViewModel.searchText)
                    coinLogoList
                    if selectedCoin != nil {
                        portfolioInputSection
                    }
                }
            }
            .navigationTitle("Edit Portfolio")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    XMarkButton {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingNavBarButton
                }
            }
            .background(Color.theme.background.ignoresSafeArea())
            .onChange(of: homeViewModel.searchText) { newValue in
                if newValue.isEmpty {
                    removeSelectedCoin()
                }
            }
        }
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView()
            .environmentObject(dev.homeViewModel)
    }
}

extension PortfolioView {
    
    private var coinLogoList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(homeViewModel.searchText.isEmpty ? homeViewModel.portfolioCoins : homeViewModel.allCoins) { coin in
                    CoinLogoView(coin: coin)
                        .frame(width: 75)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    coin.id == selectedCoin?.id ?
                                    Color.theme.green : Color.clear,
                                    lineWidth: 1
                                )
                        )
                        .onTapGesture {
                            withAnimation(.easeIn) {
                                updateSelectedCoin(coin: coin)
                            }
                        }
                }
            }
            .padding(.vertical, 4)
            .padding(.leading)
        }
    }
    
    private var portfolioInputSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Current price of \(selectedCoin?.symbol.uppercased() ?? ""):")
                Spacer()
                Text(selectedCoin?.currentPrice.asCurrencyWith6Decimals() ?? "")
            }
            Divider()
            HStack {
                Text("Amount holding:")
                Spacer()
                TextField("Ex: 1.4", text: $quantityText)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
            Divider()
            HStack {
                Text("Current value:")
                Spacer()
                Text("\(getCurrentValue().asCurrencyWith2Decimals())")
            }
        }
        .animation(.none, value: UUID())
        .padding()
        .font(.headline)
    }
    
    private var trailingNavBarButton: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark")
                .opacity(showCheckmark ? 1 : 0)
            Button {
                saveButtonPressed()
            } label: {
                Text("SAVE")
            }
            .opacity(
                selectedCoin?.currentHoldings != Double(quantityText) ? 1 : 0
            )
        }
        .font(.headline)
    }
    
    private func updateSelectedCoin(coin: CoinModel) {
        selectedCoin = coin
        if let portfolioCoin = homeViewModel.portfolioCoins.first(where: { $0.id == selectedCoin?.id }),
            let currentHoldings = portfolioCoin.currentHoldings {
            quantityText = String(currentHoldings)
        } else {
            quantityText = ""
        }
    }
    
    private func getCurrentValue() -> Double {
        guard
            let quantity = Double(quantityText),
            let currentPrice = selectedCoin?.currentPrice
        else { return 0 }
        
        return quantity * currentPrice
    }
    
    private func saveButtonPressed() {
        guard
            let coin = selectedCoin,
            let amount = Double(quantityText)
        else { return }
        
        homeViewModel.updatePortfolio(coin: coin, amount: amount)
        
        withAnimation(.easeIn) {
            showCheckmark = true
            removeSelectedCoin()
        }
        
        UIApplication.shared.endEditing()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut) {
                showCheckmark = false
            }
        }
    }
    
    private func removeSelectedCoin() {
        selectedCoin = nil
        quantityText = ""
    }
}
