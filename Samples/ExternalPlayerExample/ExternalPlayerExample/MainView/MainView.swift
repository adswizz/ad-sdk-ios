//
//  MainView.swift
//  ExternalPlayerExample
//
//  Created by George Mihoc on 20.01.2026.
//

import AdswizzExamplesCommon
import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    
    var body: some View {
        NavigationView {
            LogsScrollView(logs: viewModel.logs)
                .navigationTitle(viewModel.title)
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
