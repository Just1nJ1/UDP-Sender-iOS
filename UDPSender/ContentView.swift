//
//  ContentView.swift
//  UDPSender
//
//  Created by Justin on 7/6/23.
//

import SwiftUI
import Network

struct ContentView: View {
    @State var ip_address: String = "127.0.0.1"
    @State var port_number: String = "6666"
    @State var message: String = "Hello World!"
    @State var connection: NWConnection?
    @State var is_connected: Bool = false
    @State var log_message: String = "Disconnected"
    var body: some View {
        VStack {
            LazyVGrid (columns: [GridItem(spacing: 50, alignment: .trailing), GridItem()]) {
                Text("IP Address:")
                TextField("IP Address", text: $ip_address)
                    .frame(maxWidth: 200)
                    .background(Color.gray)
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
                if is_connected {
                    Button("Send") {
                        udp_send(message.data(using: .utf8)!)
                    }
                }
            }
            .padding()
            ScrollView(.vertical) {
                Text("\(log_message)")
            }
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
                    guard let data = data else { return }
                    NSLog("Received message: " + String(decoding: data, as: UTF8.self))
                }
            }
        }))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
