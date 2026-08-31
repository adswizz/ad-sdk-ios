//
//  MainView.swift
//  BasicAnalyticsExample
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button {
                                viewModel.stopTest()
                            } label: {
                                Image(systemName: "stop.fill")
                            }
                            Button {
                                viewModel.runAgain()
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
