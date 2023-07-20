//
//  ContentView.swift
//  UDPSender
//
//  Created by Justin on 7/6/23.
//

import SwiftUI
import SBBML
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
        if view_model.initialization {
            InitializationView(detectedObjectsViewModel: object_detection_view_model, controllerViewModel: view_model)
        } else if view_model.is_detecting {
            ObjectDetectionView(detectedObjectsViewModel: object_detection_view_model, controllerViewModel: view_model, with_detection: true)
        } else {
            ControllingView(detectedObjectsViewModel: object_detection_view_model, controllerViewModel: view_model)
        }
    }
}


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

struct InitializationView: View {
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
//                    sending = sending || pressing_up || pressing_down || pressing_left || pressing_right || pressing_lift || pressing_drop
//                    if sending && !controllerViewModel.cooldown && controllerViewModel.connection?.state == NWConnection.State.ready {
//                        controllerViewModel.update_pos()
//                        sending = false
//                    }
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

struct ControllingView: View {
    @ObservedObject var detectedObjectsViewModel: DetectedObjectsViewModel
    @ObservedObject var controllerViewModel: iOSControllerViewModel
    
    var body: some View {
        VStack {
            LazyVGrid (columns: [GridItem(spacing: 50, alignment: .trailing), GridItem()]) {
                Group {
                    Text("IP Address:")
                    TextField("IP Address", text: $controllerViewModel.ip_address)
                        .frame(maxWidth: 200)
                        .background(Color.gray)
                        .submitLabel(.continue)
                    Text("Port:")
                    TextField("Port", text: $controllerViewModel.port_number)
                        .frame(maxWidth: 200)
                        .background(Color.gray)
                        .keyboardType(.numberPad)
                    Text("Message:")
                    TextField("Message", text: $controllerViewModel.message)
                        .frame(maxWidth: 200)
                        .background(Color.gray)
                    if !controllerViewModel.is_connected {
                        Button("Connect") {
                            controllerViewModel.is_connected = true
                            controllerViewModel.udp_connect()
                        }
                    } else {
                        Button("Disconnect") {
                            controllerViewModel.is_connected = false
                            controllerViewModel.udp_disconnect()
                        }
                    }
                }
                Group {
                    Button("Send") {
                        controllerViewModel.send_message()
                    }
                    Text("X Coordinate")
                    VStack {
                        Slider(value: Binding(get: {
                            controllerViewModel.model.x_cart_coord
                        }, set: { (newVal) in
                            controllerViewModel.model.x_cart_coord = newVal
                            controllerViewModel.update_pos()
                        }), in: 133.5...262.8) { _ in
                            controllerViewModel.update_pos()
                        }
                        Text("\(controllerViewModel.model.x_cart_coord)")
                    }
                    Text("Y Coordinate")
                    VStack {
                        Slider(value: Binding(get: {
                            controllerViewModel.model.y_cart_coord
                        }, set: { (newVal) in
                            controllerViewModel.model.y_cart_coord = newVal
                            controllerViewModel.update_pos()
                        }), in: -144.1...144.1) { _ in
                            controllerViewModel.update_pos()
                        }
                        Text("\(controllerViewModel.model.y_cart_coord)")
                    }
                    Text("Z Coordinate")
                    VStack {
                        Slider(value: Binding(get: {
                            controllerViewModel.model.z_cart_coord
                        }, set: { (newVal) in
                            controllerViewModel.model.z_cart_coord = newVal
                            controllerViewModel.update_pos()
                        }), in: 11.1...284.5) { _ in
                            controllerViewModel.update_pos()
                        }
                        //                            Slider(value: $controllerViewModel.model.z_cart_coord)
                        Text("\(controllerViewModel.model.z_cart_coord)")
                    }
                    Button("Start Initialization") {
                        controllerViewModel.start_initialization()
                    }
                    Button("Start Detection") {
                        controllerViewModel.start_detection()
                    }
                }
                .opacity(controllerViewModel.is_connected ? 1 : 0)
            }
            .padding()
            HStack {
                Spacer()
            }
            ScrollView(.vertical) {
                Text("\(controllerViewModel.log_message)")
            }
            ArrowKeyView(detectedObjectsViewModel: detectedObjectsViewModel, controllerViewModel: controllerViewModel)
        }
        .padding(.all)
    }
}
