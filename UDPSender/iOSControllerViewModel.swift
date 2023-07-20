//
//  iOSControllerViewModel.swift
//  UDPSender
//
//  Created by Justin on 7/8/23.
//

import SwiftUI
import Network

class iOSControllerViewModel: ObservableObject {
    @Published var model: iOSControllerModel = iOSControllerModel()
    @Published var ip_address: String = "192.168.0.101"
    @Published var port_number: String = "6666"
    @Published var message: String = "Hello World!"
    @Published var connection: NWConnection?
    @Published var is_connected: Bool = false
    @Published var log_message: String = "Disconnected"
    
    @Published var robot_pos_tl_x: Float = 0
    @Published var robot_pos_tl_y: Float = 0
    @Published var robot_pos_br_x: Float = 0
    @Published var robot_pos_br_y: Float = 0
    @Published var robot_camera_x_ratio: Float = 0
    @Published var robot_camera_y_ratio: Float = 0
    
    var dest_pos_x: [Float] = []
    var dest_pos_y: [Float] = []
    var dest_pos_z: [Float] = []
    @Published var dest_pos_count: Int = 0
    
    @Published var start_gripping: Bool = false
    @Published var target_pos: CGRect = CGRectNull
    
    @Published var is_calibrating: Bool = false
    @Published var is_detecting: Bool = false
    
    var cooldown: Bool = false
    var legacy: Bool = false
    
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
                self.connection!.receiveMessage { (data, context, isComplete, error) in
                    guard let data = data else {
                        NSLog("No feedback")
                        return
                    }
                    NSLog(String(decoding: data, as: UTF8.self))
//                    self.log_message = String(decoding: data, as: UTF8.self)
//                    self.objectWillChange.send()
                }
            }
        }))
        
    }
    
    func grip(pos: CGRect) -> () {
        let robot_x = Float(pos.midX) * robot_camera_x_ratio + robot_pos_tl_x
        let robot_y = Float(pos.midY) * robot_camera_y_ratio + robot_pos_tl_y
        let robot_z: Float = 50 // TODO: Depth detection is needed
        model.x_cart_coord = robot_x
        model.y_cart_coord = robot_y
        model.z_cart_coord = robot_z
        move_cartesian(x: robot_x, y: robot_y, z: robot_z)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.suction_cup_on()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.model.z_cart_coord = robot_z + 50
                self.move_cartesian(x: robot_x, y: robot_y, z: robot_z + 50)
            }
        }
    }
    
    func drop(x: Float, y: Float, z: Float) -> () {
        move_cartesian(x: x, y: y, z: z)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.suction_cup_off()
        }
    }
    
    func suction_cup_on() -> () {
        udp_send("M3S1000".data(using: .utf8)!)
    }
    
    func suction_cup_off() -> () {
        udp_send("M3S0".data(using: .utf8)!)
    }
    
    func move_cartesian(x: Float, y: Float, z: Float) -> () {
        udp_send("M20 G90 G00 X\(x) Y\(y) Z\(z)".data(using: .utf8)!)
    }
    
    func send_message() -> () {
        udp_send(message.data(using: .utf8)!)
    }
    
    func update_pos() -> () {
        if !cooldown {
            move_cartesian(x: model.x_cart_coord, y: model.y_cart_coord, z: model.z_cart_coord)
            cooldown = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.cooldown = false
            }
        } else {
            legacy = true
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) {_ in
                if self.legacy {
                    self.legacy = false
                    self.update_pos()
                }
            }
        }
    }
    
    func start_initialization() -> () {
        is_calibrating = true
    }
    
    func end_initialization(size: CGSize) -> () {
        is_calibrating = false
        robot_camera_x_ratio = (robot_pos_br_x - robot_pos_tl_x) / Float(size.width)
        robot_camera_y_ratio = (robot_pos_br_y - robot_pos_tl_y) / Float(size.height)
    }
    
    func start_detection() -> () {
        is_detecting = true
    }
    
    func end_detection() -> () {
        is_detecting = false
    }
    
    func record_tl() -> () {
        robot_pos_tl_x = model.x_cart_coord
        robot_pos_tl_y = model.y_cart_coord
    }
    
    func record_br() -> () {
        robot_pos_br_x = model.x_cart_coord
        robot_pos_br_y = model.y_cart_coord
    }
    
    func picking_top_n(n: Int, objects: [CGRect]) -> () {
        let k: Int = n < objects.count ? n : objects.count
        var count = 0
        _ = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) {t in
//            NSLog("Helloworld\(count)")
            self.grip(pos: objects[count])
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                self.drop(x: self.dest_pos_x[count % self.dest_pos_count], y: self.dest_pos_y[count % self.dest_pos_count], z: self.dest_pos_z[count % self.dest_pos_count])
            }
            count += 1
            if count >= k {
                t.invalidate()
            }
        }
    }
    
    func delay(_ delay: Double, closure:@escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func add_dest_pos() -> () {
        dest_pos_x.append(model.x_cart_coord)
        dest_pos_y.append(model.y_cart_coord)
        dest_pos_z.append(model.z_cart_coord)
        dest_pos_count += 1
    }
    
    func increment(axis: iOSControllerModel.axises, increment: Float) -> () {
        model.increment(axis: axis, increment: increment)
        update_pos()
    }
}
