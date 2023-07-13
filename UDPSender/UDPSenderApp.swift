//
//  UDPSenderApp.swift
//  UDPSender
//
//  Created by Justin on 7/6/23.
//

import SwiftUI

@main
struct UDPSenderApp: App {
    var view_model: iOSControllerViewModel = iOSControllerViewModel()
    var object_detection_view_model = DetectedObjectsViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView(object_detection_view_model: object_detection_view_model, view_model: view_model)
        }
    }
}
