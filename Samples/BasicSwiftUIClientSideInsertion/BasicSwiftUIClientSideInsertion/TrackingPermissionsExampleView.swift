//
//  TrackingPermissionsExampleView.swift
//  BasicSwiftUIClientSideInsertion
//
//  Created by Adrian Manolache on 11.11.2021.
//

import SwiftUI
import AdswizzSDK

struct TrackingPermissionsExampleView: View {
    @State var showingTrackingController: Bool = false
    @State private var trackingStatus: TrackingStatus = .unknown
    
    var body: some View {
        ZStack {
            BackgroundView()
                .sheet(isPresented: $showingTrackingController) {
                    TrackingController(result: $trackingStatus)
                        .ignoresSafeArea().onDisappear {
                            showingTrackingController = false
                        }
                }
            VStack {
                Button {
                    showingTrackingController = TrackingController.canPresentController()
                } label: {
                    Text("Tap for tracking permissions")
                        .padding()
                        .background(Color(uiColor: UIColor.systemBlue))
                        .cornerRadius(25)
                        .foregroundColor(Color.white)
                }
                Text("The TrackingPermissionController (UIViewController subclass) can be used in a Host App to easily request the IDFA permission through a friendly ready-made container.\n\n This controller can be presented as is or customized before presentation using a configuration object.\n\nIf permissions have already been granted tapping the button will have no effect").padding()
            }
        }
    }
}

struct BackgroundView: View {
    var body: some View {
        ZStack {
            Color.white
        }
    }
}

