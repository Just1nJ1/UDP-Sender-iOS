//
//  ControllingView.swift
//  IOSController
//
//  Created by Justin on 7/21/23.
//

import SwiftUI

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
                    Button("Start Calibration") {
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


struct ControllingView_Previews: PreviewProvider {
    static var view_model: iOSControllerViewModel = iOSControllerViewModel()
    static var object_detection_view_model = DetectedObjectsViewModel()
    
    static var previews: some View {
        ControllingView(detectedObjectsViewModel: object_detection_view_model, controllerViewModel: view_model)
    }
}
