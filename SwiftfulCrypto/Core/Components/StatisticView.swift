//
//  StatisticView.swift
//  SwiftfulCrypto
//
//  Created by Lucas Ramos on 08/10/22.
//

import SwiftUI

struct StatisticView: View {
    
    let statistic: StatisticModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(statistic.title)
                .font(.caption)
                .foregroundColor(.theme.secondaryText)
            Text(statistic.value)
                .font(.headline)
                .foregroundColor(.theme.accent)
            HStack(spacing: 4) {
                Image(systemName: "triangle.fill")
                    .font(.caption2)
                    .rotationEffect(.degrees(positivePercentageChange ? 0 : 180))
                Text(statistic.percentageChange?.asPercentString() ?? "")
                    .font(.caption)
                    .bold()
            }
            .foregroundColor(positivePercentageChange ? .theme.green : .theme.red)
            .opacity(statistic.percentageChange == nil ? 0 : 1)
        }
    }
}

struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StatisticView(statistic: dev.marketCapStats)
                .previewLayout(.sizeThatFits)
            StatisticView(statistic: dev.marketCapStats)
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
            StatisticView(statistic: dev.totalVolumeStats)
                .previewLayout(.sizeThatFits)
            StatisticView(statistic: dev.totalVolumeStats)
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
            StatisticView(statistic: dev.portfolioStats)
                .previewLayout(.sizeThatFits)
            StatisticView(statistic: dev.portfolioStats)
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }
        .padding()
    }
}

extension StatisticView {
    private var positivePercentageChange: Bool {
        return (statistic.percentageChange ?? 0) >= 0
    }
}
