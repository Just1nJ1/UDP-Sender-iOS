//
//  iOSControllerModel.swift
//  UDPSender
//
//  Created by Justin on 7/8/23.
//

import Foundation

struct iOSControllerModel {
    var x_cart_coord: Float = 0
    var y_cart_coord: Float = 0
    var z_cart_coord: Float = 0
    var message_interval: Double = 0.5
    
    enum axises: Int {
        case x = 0
        case y = 1
        case z = 2
    }
    
    mutating func increment(axis: axises, increment: Float) -> Void {
        switch axis {
        case .x:
            x_cart_coord += increment
            if -120 > x_cart_coord {
                x_cart_coord = -120
            } else if x_cart_coord > 120 {
                x_cart_coord = 120
            }
        case .y:
            y_cart_coord += increment
            if -120 > y_cart_coord {
                y_cart_coord = -120
            } else if y_cart_coord > 120 {
                y_cart_coord = 120
            }
        case .z:
            z_cart_coord += increment
            if -120 > z_cart_coord {
                z_cart_coord = -120
            } else if z_cart_coord > 120 {
                z_cart_coord = 120
            }
        }
    }
    
    mutating func set_value(axis: axises, value: Float) -> Void {
        var val = value
        if value > 120 {
            val = 120
        } else if value < -120 {
            val = -120
        }
        
        switch axis {
        case .x: x_cart_coord = val
        case .y: y_cart_coord = val
        case .z: z_cart_coord = val
        }
    }
}
