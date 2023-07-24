//
//  ViewModel.swift
//  SSBML
//
//  Created by Justin on 7/10/23.
//

import Foundation
import SBBML
import Combine

class DetectedObjectsViewModel: ObservableObject {
    
    @Published var detectedObjects = [DetectedObject]()
    private var detectedObjectsSubscription: AnyCancellable!

    var objectDetectionService: ObjectDetectionService
    
//    @Published var is_detecting: Bool = false
    
    init() {
        let modelFileName = "converted_model_640_detection_float32"  //
        let configuration = ObjectDetectionServiceConfiguration(objectDetectionRate: 0)     // use custom config if desired
        self.objectDetectionService = ObjectDetectionService(modelFileName: modelFileName, configuration: configuration)
        
        detectedObjectsSubscription = objectDetectionService.detectedObjectsPublisher
            .sink(receiveValue: { [weak self] detectedObjects in
                self?.detectedObjects = detectedObjects
            })
    }
}
