//
//  MainView.swift
//  BasicTrackingPermissionExample
//
//  Created by George Mihoc on 22.01.2026.
//

import AdswizzExamplesCommon
import AdswizzSDK
import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @SwiftUI.Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    viewModel.presentTrackingPermission(isDarkMode: colorScheme == .dark)
                }) {
                    Text("Show Tracking Permission")
                        .font(.system(size: 17, weight: .bold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                Divider()

                LogsScrollView(
                    logs: viewModel.logs,
                    font: .system(size: 14, design: .monospaced)
                )
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showTrackingController) {
                TrackingPermissionRepresentable(viewModel: viewModel, isDarkMode: colorScheme == .dark)
                    .ignoresSafeArea()
            }
            .alert("Tracking Permission", isPresented: $viewModel.showStatusAlert) {
                Button("Open Settings") { viewModel.openAppSettings() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(viewModel.statusAlertMessage)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct TrackingPermissionRepresentable: UIViewControllerRepresentable {
    let viewModel: MainViewModel
    let isDarkMode: Bool

    func makeUIViewController(context: Context) -> TrackingPermissionController {
        viewModel.makeTrackingController(isDarkMode: isDarkMode)
    }

    func updateUIViewController(_ uiViewController: TrackingPermissionController, context: Context) {}
}

#Preview {
    MainView()
}
