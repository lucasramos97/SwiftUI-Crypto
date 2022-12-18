//
//  HomeView.swift
//  SwiftfulCrypto
//
//  Created by Lucas Ramos on 01/10/22.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @State private var showPortfolio = false
    @State private var showPortfolioView = false
    @State private var selectedCoin: CoinModel? = nil
    @State private var showDetailView = false
    @State private var showSettingsView = false
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
                .sheet(isPresented: $showPortfolioView) {
                    PortfolioView()
                        .environmentObject(homeViewModel)
                }
            
            VStack {
                homeHeader
                HomeStatisticsView(showPortfolio: $showPortfolio)
                SearchBarView(searchText: $homeViewModel.searchText)
                columnTitles
                if !showPortfolio {
                    allCoinsList
                        .transition(.move(edge: .leading))
                }
                if showPortfolio {
                    ZStack(alignment: .top) {
                        if homeViewModel.portfolioCoins.isEmpty
                            && homeViewModel.searchText.isEmpty {
                            portfolioEmptyText
                        } else {
                            portfolioCoinsList
                        }
                    }
                    .transition(.move(edge: .trailing))
                }
                Spacer(minLength: 0)
            }
            .sheet(isPresented: $showSettingsView) {
                SettingsView()
            }
        }
        .background(
            NavigationLink(isActive: $showDetailView, destination: {
                DetailLoadingView(coin: $selectedCoin)
            }, label: {
                EmptyView()
            })
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
                .navigationBarHidden(true)
        }
        .environmentObject(dev.homeViewModel)
    }
}

extension HomeView {
    
    private var homeHeader: some View {
        HStack {
            CircleButtonView(iconName: showPortfolio ? "plus" : "info")
                .animation(.none, value: showPortfolio)
                .background(
                    CircleButtonAnimationView(animate: $showPortfolio)
                )
                .onTapGesture {
                    if showPortfolio {
                        showPortfolioView.toggle()
                    } else {
                        showSettingsView.toggle()
                    }
                }
            Spacer()
            Text(showPortfolio ? "Portfolio" : "Live Prices")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(.theme.accent)
                .animation(.none, value: showPortfolio)
            Spacer()
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(.degrees(showPortfolio ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring()) {
                        showPortfolio.toggle()
                    }
                }
        }
        .padding(.horizontal)
    }
    
    private var columnTitles: some View {
        HStack {
            HStack(spacing: 4) {
                Text("Coin")
                Image(systemName: "chevron.down")
                    .opacity(
                        homeViewModel.sortOption == .rank ||
                        homeViewModel.sortOption == .rankReversed
                        ? 1 : 0
                    )
                    .rotationEffect(.degrees(
                        homeViewModel.sortOption == .rank ? 0 : 180
                    ))
            }
            .onTapGesture {
                withAnimation(.default) {
                    homeViewModel.sortOption =
                    homeViewModel.sortOption == .rank ? .rankReversed : .rank
                }
            }
            Spacer()
            if showPortfolio {
                HStack(spacing: 4) {
                    Text("Holdings")
                    Image(systemName: "chevron.down")
                        .opacity(
                            homeViewModel.sortOption == .holdings ||
                            homeViewModel.sortOption == .holdingsReversed
                            ? 1 : 0
                        )
                        .rotationEffect(.degrees(
                            homeViewModel.sortOption == .holdings ? 0 : 180
                        ))
                }
                .onTapGesture {
                    withAnimation(.default) {
                        homeViewModel.sortOption =
                        homeViewModel.sortOption == .holdings
                        ? .holdingsReversed : .holdings
                    }
                }
            }
            HStack(spacing: 4) {
                Text("Price")
                Image(systemName: "chevron.down")
                    .opacity(
                        homeViewModel.sortOption == .price ||
                        homeViewModel.sortOption == .priceReversed
                        ? 1 : 0
                    )
                    .rotationEffect(.degrees(
                        homeViewModel.sortOption == .price ? 0 : 180
                    ))
            }
            .frame(width: UIScreen.main.bounds.width / 3.5, alignment: .trailing)
            .onTapGesture {
                withAnimation(.default) {
                    homeViewModel.sortOption =
                    homeViewModel.sortOption == .price ? .priceReversed : .price
                }
            }
            Button {
                withAnimation(.linear(duration: 2)) {
                    homeViewModel.reloadData()
                }
            } label: {
                Image(systemName: "goforward")
            }
            .rotationEffect(.degrees(homeViewModel.isLoading ? 360 : 0), anchor: .center)
        }
        .font(.caption)
        .foregroundColor(.theme.secondaryText)
        .padding(.horizontal)
    }
    
    private var allCoinsList: some View {
        List {
            ForEach(homeViewModel.allCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: false)
                        .listRowInsets(.init(
                            top: 10, leading: 0, bottom: 10, trailing: 10
                        ))
                        .listRowBackground(Color.theme.background)
                        .onTapGesture {
                            segue(coin: coin)
                        }
            }
        }
        .listStyle(.plain)
    }
    
    private var portfolioCoinsList: some View {
        List {
            ForEach(homeViewModel.portfolioCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: true)
                    .listRowInsets(.init(
                        top: 10, leading: 0, bottom: 10, trailing: 10
                    ))
                    .listRowBackground(Color.theme.background)
                    .onTapGesture {
                        segue(coin: coin)
                    }
            }
        }
        .listStyle(.plain)
    }
    
    private var portfolioEmptyText: some View {
        Text("You haven't added any coins to your portfolio yet. Click the + button to get started! 🧐")
            .font(.callout)
            .fontWeight(.medium)
            .foregroundColor(.theme.accent)
            .multilineTextAlignment(.center)
            .padding(40)
    }
    
    private func segue(coin: CoinModel) {
        selectedCoin = coin
        showDetailView.toggle()
    }
}
