//
//  ObjectDetectionView.swift
//  IOSController
//
//  Created by Justin on 7/21/23.
//

import SwiftUI
import SBBML

struct ObjectDetectionView: View {
    @ObservedObject var detectedObjectsViewModel: DetectedObjectsViewModel
    @ObservedObject var controllerViewModel: iOSControllerViewModel
    @State var with_detection: Bool
    var body: some View {
        if with_detection {
            ZStack {
                CameraStreamView(objectDetectionService: detectedObjectsViewModel.objectDetectionService)
                    .overlay(
                        Group {
                            ForEach(detectedObjectsViewModel.detectedObjects) { detectedObject in
                                let pos = detectedObject.rectInPreviewLayer
                                Rectangle()
                                    .strokeBorder(Color.white, lineWidth: 4)
                                    .frame(width: pos.width, height: pos.height)
                                    .position(x: pos.midX, y: pos.midY)
                                Text("\(detectedObject.confidence)")
                                    .position(x: pos.midX, y: pos.midY)
                                Text("\(detectedObject.label)")
                                    .position(x: pos.midX, y: pos.midY - 20)
                                Text("\(pos.midX), \(pos.midY)")
                                    .position(x: pos.midX, y: pos.midY + 20)
                            }
                        }
                    )
                VStack {
                    Spacer()
                    HStack {
                        Button("End Detection") {
                            controllerViewModel.end_detection()
                        }
                        Spacer()
                        Button("Picking Top 3") {
                            let sorted = detectedObjectsViewModel.detectedObjects.sorted(by: { A, B in
                                A.confidence > B.confidence
                            })
                            let positions = sorted.map{$0.rectInPreviewLayer}
                            controllerViewModel.picking_top_n(n: 3, objects: positions)
                        }
                    }
                }
            }
        } else {
            CameraStreamView(objectDetectionService: detectedObjectsViewModel.objectDetectionService)
        }
    }
}

struct ObjectDetectionView_Previews: PreviewProvider {
    static var view_model: iOSControllerViewModel = iOSControllerViewModel()
    static var object_detection_view_model = DetectedObjectsViewModel()
    
    static var previews: some View {
        ObjectDetectionView(detectedObjectsViewModel: object_detection_view_model, controllerViewModel: view_model, with_detection: true)
    }
}
