//
//  ContentView.swift
//  UDPSender
//
//  Created by Justin on 7/6/23.
//

import SwiftUI
import Network

struct ContentView: View {
    @State var action_view: Bool = false
    
    
    @ObservedObject var object_detection_view_model: DetectedObjectsViewModel
    @ObservedObject var view_model: iOSControllerViewModel
    
//    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
//        ObjectDetectionView(detectedObjectsViewModel: object_detection_view_model, controllerViewModel: view_model, with_detection: true)
//        InitializationView(detectedObjectsViewModel: object_detection_view_model, controllerViewModel: view_model)
//        ControllingView(detectedObjectsViewModel: object_detection_view_model, controllerViewModel: view_model)
        if view_model.is_calibrating {
            CalibrationView(detectedObjectsViewModel: object_detection_view_model, controllerViewModel: view_model)
        } else if view_model.is_detecting {
            ObjectDetectionView(detectedObjectsViewModel: object_detection_view_model, controllerViewModel: view_model, with_detection: true)
        } else {
            ControllingView(detectedObjectsViewModel: object_detection_view_model, controllerViewModel: view_model)
        }
    }
}
