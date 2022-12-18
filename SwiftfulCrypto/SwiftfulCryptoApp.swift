//
//  SwiftfulCryptoApp.swift
//  SwiftfulCrypto
//
//  Created by Lucas Ramos on 01/10/22.
//

import SwiftUI

@main
struct SwiftfulCryptoApp: App {
    
    @StateObject private var homeViewModel = HomeViewModel()
    
    @State private var showLaunchView = true
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(.theme.accent)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(.theme.accent)]
        UINavigationBar.appearance().tintColor = UIColor(.theme.accent)
        UITableView.appearance().backgroundColor = UIColor.clear
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                NavigationView {
                    HomeView()
                        .navigationBarHidden(true)
                }
                .navigationViewStyle(.stack)
                .environmentObject(homeViewModel)
                
                ZStack {
                    if showLaunchView {
                        LaunchView(showLaunchView: $showLaunchView)
                            .transition(.move(edge: .leading))
                    }
                }
                .zIndex(2)
            }
        }
    }
}
