//
//  InitializationView.swift
//  IOSController
//
//  Created by Justin on 7/21/23.
//

import SwiftUI

struct CalibrationView: View {
    @ObservedObject var detectedObjectsViewModel: DetectedObjectsViewModel
    @ObservedObject var controllerViewModel: iOSControllerViewModel
    var body: some View {
        ZStack {
            ObjectDetectionView(detectedObjectsViewModel: detectedObjectsViewModel, controllerViewModel: controllerViewModel, with_detection: false)
            GeometryReader { geometry in
                VStack {
                    Button("End Initialization") {
                        controllerViewModel.end_initialization(size: geometry.size)
                    }
//                    Spacer()
                    ScrollView {
                        VStack {
                            Text("TL Pos: \(controllerViewModel.robot_pos_tl_x), \(controllerViewModel.robot_pos_tl_y)")
                            Text("BR Pos: \(controllerViewModel.robot_pos_br_x), \(controllerViewModel.robot_pos_br_y)")
                            Text("dest Pos:")
                            ForEach (0..<controllerViewModel.dest_pos_count, id: \.self) { i in
                                Text("\(controllerViewModel.dest_pos_x[i]), \(controllerViewModel.dest_pos_y[i]), \(controllerViewModel.dest_pos_z[i])")
                            }
                        }
                    }
                    Button("Add dest pos") {
                        controllerViewModel.add_dest_pos()
                    }
                    HStack {
                        Button("Top Left") {
                            controllerViewModel.record_tl()
                        }
                        Spacer()
                        Button("Bottom Right") {
                            controllerViewModel.record_br()
                        }
                    }
                    ArrowKeyView(detectedObjectsViewModel: detectedObjectsViewModel, controllerViewModel: controllerViewModel)
                }
            }
            .padding(.all, 10.0)
        }
    }
}

struct CalibrationView_Previews: PreviewProvider {
    static var view_model: iOSControllerViewModel = iOSControllerViewModel()
    static var object_detection_view_model = DetectedObjectsViewModel()
    
    static var previews: some View {
        CalibrationView(detectedObjectsViewModel: object_detection_view_model, controllerViewModel: view_model)
    }
}
