//
//  ArrowKeyView.swift
//  IOSController
//
//  Created by Justin on 7/21/23.
//

import SwiftUI

struct ArrowKeyView: View {
    @ObservedObject var detectedObjectsViewModel: DetectedObjectsViewModel
    @ObservedObject var controllerViewModel: iOSControllerViewModel
    
    @State var pressing_up: Bool = false
    @State var pressing_down: Bool = false
    @State var pressing_left: Bool = false
    @State var pressing_right: Bool = false
    @State var pressing_lift: Bool = false
    @State var pressing_drop: Bool = false
    
    @State var sending: Bool = false
    @State var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Spacer()
            Text("")
                .onReceive(timer) { _ in
                    if pressing_up {
                        NSLog("Up")
                        controllerViewModel.increment(axis: .x, increment: 3)
                    }
                    if pressing_down {
                        NSLog("Down")
                        controllerViewModel.increment(axis: .x, increment: -3)
                    }
                    if pressing_left {
                        NSLog("Left")
                        controllerViewModel.increment(axis: .y, increment: -3)
                    }
                    if pressing_right {
                        NSLog("Right")
                        controllerViewModel.increment(axis: .y, increment: 3)
                    }
                    if pressing_lift {
                        NSLog("Lift")
                        controllerViewModel.increment(axis: .z, increment: 3)
                    }
                    if pressing_drop {
                        NSLog("Drop")
                        controllerViewModel.increment(axis: .z, increment: -3)
                    }
                }
            ForEach(1..<4) { i in
                HStack {
                    ForEach(1..<6) { j in
                        if (i == 1 && j == 2) {
                            Image(systemName: "arrow.up.square")
                                .resizable()
                                .scaledToFit()
                                .onLongPressGesture(minimumDuration: .infinity, perform: {}, onPressingChanged: { current_state in
                                    pressing_up = current_state
                                })
                        } else if (i == 1 && j == 5) {
                            Image(systemName: "arrow.up.square")
                                .resizable()
                                .scaledToFit()
                                .onLongPressGesture(minimumDuration: .infinity, perform: {}, onPressingChanged: { current_state in
                                    pressing_lift = current_state
                                })
                        } else if (i == 2 && j == 1) {
                            Image(systemName: "arrow.left.square")
                                .resizable()
                                .scaledToFit()
                                .onLongPressGesture(minimumDuration: .infinity, perform: {}, onPressingChanged: { current_state in
                                    pressing_left = current_state
                                })
                        } else if (i == 2 && j == 3) {
                            Image(systemName: "arrow.right.square")
                                .resizable()
                                .scaledToFit()
                                .onLongPressGesture(minimumDuration: .infinity, perform: {}, onPressingChanged: { current_state in
                                    pressing_right = current_state
                                })
                        } else if (i == 3 && j == 2) {
                            Image(systemName: "arrow.down.square")
                                .resizable()
                                .scaledToFit()
                                .onLongPressGesture(minimumDuration: .infinity, perform: {}, onPressingChanged: { current_state in
                                    pressing_down = current_state
                                })
                        } else if (i == 3 && j == 5) {
                            Image(systemName: "arrow.down.square")
                                .resizable()
                                .scaledToFit()
                                .onLongPressGesture(minimumDuration: .infinity, perform: {}, onPressingChanged: { current_state in
                                    pressing_drop = current_state
                                })
                        } else {
                            Rectangle()
                                .aspectRatio(1, contentMode: .fit)
                                .opacity(0)
                        }
                    }
                    
                }
            }
        }
    }
}

struct ArrowKeyView_Previews: PreviewProvider {
    static var view_model: iOSControllerViewModel = iOSControllerViewModel()
    static var object_detection_view_model = DetectedObjectsViewModel()
    
    static var previews: some View {
        ArrowKeyView(detectedObjectsViewModel: object_detection_view_model, controllerViewModel: view_model)
    }
}
