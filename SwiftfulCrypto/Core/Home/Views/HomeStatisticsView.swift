//
//  HomeStatisticsView.swift
//  SwiftfulCrypto
//
//  Created by Lucas Ramos on 08/10/22.
//

import SwiftUI

struct HomeStatisticsView: View {
    
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @Binding var showPortfolio: Bool
    
    var body: some View {
        HStack {
            ForEach(homeViewModel.statistics) { statistic in
                StatisticView(statistic: statistic)
                    .frame(width: UIScreen.main.bounds.width / 3)
            }
        }
        .frame(
            width: UIScreen.main.bounds.width,
            alignment: showPortfolio ? .trailing : .leading
        )
    }
}

struct HomeStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeStatisticsView(showPortfolio: .constant(false))
            .environmentObject(dev.homeViewModel)
    }
}
