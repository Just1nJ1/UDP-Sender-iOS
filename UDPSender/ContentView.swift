//
//  ContentView.swift
//  UDPSender
//
//  Created by Justin on 7/6/23.
//

import SwiftUI
import Network
import SBBML

struct ContentView: View {
    @State var ip_address: String = "10.236.136.102"
    @State var port_number: String = "6666"
    @State var message: String = "Hello World!"
    @State var connection: NWConnection?
    @State var is_connected: Bool = false
    @State var log_message: String = "Disconnected"
    @State var action_view: Bool = false
    @State var period: Bool = true
    
    @State var pressing_up: Bool = false
    @State var pressing_down: Bool = false
    @State var pressing_left: Bool = false
    @State var pressing_right: Bool = false
    @State var pressing_lift: Bool = false
    @State var pressing_drop: Bool = false
    
    @State var sending: Bool = false
    
    @State var initialization: Bool = false
    
    @State var robot_pos_tl_x: Float = 0
    @State var robot_pos_tl_y: Float = 0
    @State var robot_pos_br_x: Float = 0
    @State var robot_pos_br_y: Float = 0
    @State var robot_camera_x_ratio: Float = 0
    @State var robot_camera_y_ratio: Float = 0
    
    @State var start_gripping: Bool = false
    @State var target_pos: CGRect = CGRectNull
    
    @State var is_detecting: Bool = false
    
    var object_detection_view_model: DetectedObjectsViewModel
    
    @ObservedObject var view_model: iOSControllerViewModel
    
    @State var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            if is_detecting {
                ObjectDetectionView(detectedObjectsViewModel: object_detection_view_model, target_pos: $target_pos, content_view: Binding(get: {self}, set: {newval in }), with_detection: true)
//                let sorted = object_detection_view_model.detectedObjects.sorted(by: { A, B in
//                    A.confidence > B.confidence
//                })
//                if let target = sorted.first {
//                    view_model.model.set_value(axis: .x, value: Float(target.rectInPreviewLayer.midX))
//                    view_model.model.set_value(axis: .y, value: Float(target.rectInPreviewLayer.midY))
//                    view_model.model.set_value(axis: .z, value: target.depth)
//
//                }
            }
            if initialization {
                ObjectDetectionView(detectedObjectsViewModel: object_detection_view_model, target_pos: $target_pos, content_view: Binding(get: {self}, set: {newval in }), with_detection: false)
            }
            GeometryReader { geometry in
                VStack {
                    LazyVGrid (columns: [GridItem(spacing: 50, alignment: .trailing), GridItem()]) {
                        Group {
                            Text("IP Address:")
                            TextField("IP Address", text: $ip_address)
                                .frame(maxWidth: 200)
                                .background(Color.gray)
                                .submitLabel(.continue)
                            Text("Port:")
                            TextField("Port", text: $port_number)
                                .frame(maxWidth: 200)
                                .background(Color.gray)
                                .keyboardType(.numberPad)
                            Text("Message:")
                            TextField("Message", text: $message)
                                .frame(maxWidth: 200)
                                .background(Color.gray)
                            if !is_connected {
                                Button("Connect") {
                                    is_connected = true
                                    udp_connect()
                                }
                            } else {
                                Button("Disconnect") {
                                    is_connected = false
                                    udp_disconnect()
                                }
                            }
                        }
                        Group {
                            Button("Send") {
                                udp_send(message.data(using: .utf8)!)
                            }
                            Text("X Coordinate")
                            VStack {
                                Slider(value: Binding(get: {
                                    view_model.model.x_cart_coord
                                }, set: { (newVal) in
                                    view_model.model.x_cart_coord = newVal
                                    if period {
                                        period = false
                                        udp_send("M20 G90 G00 X\(view_model.model.x_cart_coord) Y\(view_model.model.y_cart_coord) Z\(view_model.model.z_cart_coord)".data(using: .utf8)!)
                                        period_timer()
                                    }
                                }), in: 133.5...262.8) { _ in
                                    udp_send("M20 G90 G00 X\(view_model.model.x_cart_coord) Y\(view_model.model.y_cart_coord) Z\(view_model.model.z_cart_coord)".data(using: .utf8)!)
                                    period = true
                                }
                                //                            Slider(value: $view_model.model.x_cart_coord)
                                Text("\(view_model.model.x_cart_coord)")
                            }
                            Text("Y Coordinate")
                            VStack {
                                Slider(value: Binding(get: {
                                    view_model.model.y_cart_coord
                                }, set: { (newVal) in
                                    view_model.model.y_cart_coord = newVal
                                    if period {
                                        period = false
                                        udp_send("M20 G90 G00 X\(view_model.model.x_cart_coord) Y\(view_model.model.y_cart_coord) Z\(view_model.model.z_cart_coord)".data(using: .utf8)!)
                                        period_timer()
                                    }
                                }), in: -144.1...144.1) { _ in
                                    udp_send("M20 G90 G00 X\(view_model.model.x_cart_coord) Y\(view_model.model.y_cart_coord) Z\(view_model.model.z_cart_coord)".data(using: .utf8)!)
                                    period = true
                                }
                                //                            Slider(value: $view_model.model.y_cart_coord)
                                Text("\(view_model.model.y_cart_coord)")
                            }
                            Text("Z Coordinate")
                            VStack {
                                Slider(value: Binding(get: {
                                    view_model.model.z_cart_coord
                                }, set: { (newVal) in
                                    view_model.model.z_cart_coord = newVal
                                    if period {
                                        period = false
                                        udp_send("M20 G90 G00 X\(view_model.model.x_cart_coord) Y\(view_model.model.y_cart_coord) Z\(view_model.model.z_cart_coord)".data(using: .utf8)!)
                                        period_timer()
                                    }
                                }), in: 11.1...284.5) { _ in
                                    period = true
                                }
                                //                            Slider(value: $view_model.model.z_cart_coord)
                                Text("\(view_model.model.z_cart_coord)")
                            }
                            Button(initialization ? "End Initialize" : "Start Initialize") {
                                initialization.toggle()
                                if !initialization {
                                    robot_camera_x_ratio = (robot_pos_br_x - robot_pos_tl_x) / Float(geometry.size.width)
                                    robot_camera_y_ratio = (robot_pos_br_y - robot_pos_tl_y) / Float(geometry.size.height)
                                }
                            }
                            if initialization {
                                Button("Top Left") {
                                    robot_pos_tl_x = view_model.model.x_cart_coord
                                    robot_pos_tl_y = view_model.model.y_cart_coord
                                }
                                Button("Bottom Right") {
                                    robot_pos_br_x = view_model.model.x_cart_coord
                                    robot_pos_br_y = view_model.model.y_cart_coord
                                }
                            }
                            Button(is_detecting ? "End Detection" : "Start Detection") {
                                is_detecting.toggle()
                            }
                        }
                        .opacity(is_connected ? 1 : 0)
                    }
                    .padding()
                    HStack {
                        Spacer()
                    }
                    ScrollView(.vertical) {
                        Text("\(log_message)")
                            .onReceive(timer) { _ in
                                if pressing_up {
                                    NSLog("Up")
                                    view_model.model.increment(axis: .x, increment: 0.1)
                                }
                                if pressing_down {
                                    NSLog("Down")
                                    view_model.model.increment(axis: .x, increment: -0.1)
                                }
                                if pressing_left {
                                    NSLog("Left")
                                    view_model.model.increment(axis: .y, increment: -0.1)
                                }
                                if pressing_right {
                                    NSLog("Right")
                                    view_model.model.increment(axis: .y, increment: 0.1)
                                }
                                if pressing_lift {
                                    NSLog("Lift")
                                    view_model.model.increment(axis: .z, increment: 0.1)
                                }
                                if pressing_drop {
                                    NSLog("Drop")
                                    view_model.model.increment(axis: .z, increment: -0.1)
                                }
                                sending = sending || pressing_up || pressing_down || pressing_left || pressing_right || pressing_lift || pressing_drop
                                if sending && period && connection?.state == NWConnection.State.ready {
                                    udp_send("M20 G90 G00 X\(view_model.model.x_cart_coord) Y\(view_model.model.y_cart_coord) Z\(view_model.model.z_cart_coord)".data(using: .utf8)!)
                                    sending = false
                                    period = false
                                    period_timer()
                                }
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
                                    //                                    .foregroundColor(.white)
                                        .opacity(0)
                                }
                            }
                            
                        }
                    }
                }
                .padding(.all)
            }
        }
    }
    
    func period_timer() -> (){
        DispatchQueue.main.asyncAfter(deadline: .now() + view_model.model.message_interval) {
            period = true
        }
    }
    
    func udp_connect() -> (){
        if connection != nil && connection?.state != .cancelled {}
        else {
            connection = NWConnection(host: NWEndpoint.Host(ip_address), port: NWEndpoint.Port(port_number)!, using: .udp)
            connection!.stateUpdateHandler = { (newState) in
                switch (newState) {
                case .preparing:
                    NSLog("Entered state: preparing")
                case .ready:
                    NSLog("Entered state: ready")
                case .setup:
                    NSLog("Entered state: setup")
                case .cancelled:
                    NSLog("Entered state: cancelled")
                case .waiting:
                    NSLog("Entered state: waiting")
                case .failed:
                    NSLog("Entered state: failed")
                default:
                    NSLog("Entered an unknown state")
                }
            }
            
            connection!.viabilityUpdateHandler = { (isViable) in
                if (isViable) {
                    NSLog("Connection is viable")
                } else {
                    NSLog("Connection is not viable")
                }
            }
            
            connection!.betterPathUpdateHandler = { (betterPathAvailable) in
                if (betterPathAvailable) {
                    NSLog("A better path is availble")
                } else {
                    NSLog("No better path is available")
                }
            }
            
            connection!.start(queue: .global())
            log_message = "Connected"
        }
    }
    
    func udp_disconnect() -> (){
        log_message = "Disconnected"
        connection?.cancel()
    }
    
    func udp_send(_ payload: Data) -> (){
        connection!.send(content: payload, completion: .contentProcessed({ error in
            if let error = error {
                NSLog("Unable to process and send the data: \(error)")
            } else {
                NSLog("Data has been sent")
                connection!.receiveMessage { (data, context, isComplete, error) in
                    guard let data = data else {
                        NSLog("No feedback")
                        return
                    }
                    NSLog(String(decoding: data, as: UTF8.self))
                    log_message = String(decoding: data, as: UTF8.self)
                }
            }
        }))
    }
    
    func grip(pos: CGRect) -> () {
        let robot_x = Float(pos.midX) * robot_camera_x_ratio + robot_pos_tl_x
        let robot_y = Float(pos.midY) * robot_camera_y_ratio + robot_pos_tl_y
        let robot_z: Float = 50 // TODO: Depth detection is needed
        view_model.model.x_cart_coord = robot_x
        view_model.model.y_cart_coord = robot_y
        view_model.model.z_cart_coord = robot_z
        move_cartesian(x: robot_x, y: robot_y, z: robot_z)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            suction_cup_on()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                view_model.model.z_cart_coord = robot_z + 50
                move_cartesian(x: robot_x, y: robot_y, z: robot_z + 50)
            }
        }
    }
    
    func suction_cup_on() -> () {
        udp_send("M3S1000".data(using: .utf8)!)
    }
    
    func move_cartesian(x: Float, y: Float, z: Float) -> () {
        udp_send("M20 G90 G00 X\(x) Y\(y) Z\(z)".data(using: .utf8)!)
    }
}


struct ObjectDetectionView: View {
    @ObservedObject var detectedObjectsViewModel: DetectedObjectsViewModel
    @Binding var target_pos: CGRect
    @Binding var content_view: ContentView // TODO: this is for selecting detected object purpose. Should be removed
    @State var with_detection: Bool
    var body: some View {
        if with_detection {
            CameraStreamView(objectDetectionService: detectedObjectsViewModel.objectDetectionService)
                .overlay(
                    Group {
                        ForEach(detectedObjectsViewModel.detectedObjects) { detectedObject in
                            //                    let sorted = detectedObjectsViewModel.detectedObjects.sorted(by: { A, B in
                            //                        A.confidence > B.confidence
                            //                    })
                            //                    if let detectedObject = sorted.first {
                            let pos = detectedObject.rectInPreviewLayer
                            Rectangle()
                                .strokeBorder(Color.white, lineWidth: 4)
                                .frame(width: pos.width, height: pos.height)
                                .position(x: pos.midX, y: pos.midY)
                            Button("|||||||||||||||||||||"){
                                target_pos = pos
                                content_view.grip(pos: pos)
                            }
                            .frame(width: pos.width, height: pos.height)
                            .position(x: pos.midX, y: pos.midY)
                            .zIndex(100)
                            .foregroundColor(.black)
                            Text("\(detectedObject.confidence)")
                                .position(x: pos.midX, y: pos.midY)
                            //                        Text("\(detectedObject.depth!)")
                            //                            .position(x: pos.midX, y: pos.midY + 20)
                            Text("\(detectedObject.label)")
                                .position(x: pos.midX, y: pos.midY - 20)
                            Text("\(pos.midX), \(pos.midY)")
                                .position(x: pos.midX, y: pos.midY + 20)
                        }
                    }
                )
        } else {
            CameraStreamView(objectDetectionService: detectedObjectsViewModel.objectDetectionService)
        }
    }
}
