//
//  iOSControllerModel.swift
//  UDPSender
//
//  Created by Justin on 7/8/23.
//

import Foundation

struct iOSControllerModel {
    var x_cart_coord: Float = 198.67
    var y_cart_coord: Float = 0
    var z_cart_coord: Float = 230.72
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
            if 133.5 > x_cart_coord {
                x_cart_coord = 133.5
            } else if x_cart_coord > 262.8 {
                x_cart_coord = 262.8
            }
        case .y:
            y_cart_coord += increment
            if -144.1 > y_cart_coord {
                y_cart_coord = -144.1
            } else if y_cart_coord > 144.1 {
                y_cart_coord = 144.1
            }
        case .z:
            z_cart_coord += increment
            if 11.1 > z_cart_coord {
                z_cart_coord = 11.1
            } else if z_cart_coord > 284.5 {
                z_cart_coord = 284.5
            }
        }
    }
    
    mutating func set_value(axis: axises, value: Float) -> Void {
        switch axis {
        case .x:
            x_cart_coord = value
            if 133.5 > x_cart_coord {
                x_cart_coord = 133.5
            } else if x_cart_coord > 262.8 {
                x_cart_coord = 262.8
            }
        case .y:
            y_cart_coord = value
            if -144.1 > y_cart_coord {
                y_cart_coord = -144.1
            } else if y_cart_coord > 144.1 {
                y_cart_coord = 144.1
            }
        case .z:
            z_cart_coord = value
            if 11.1 > z_cart_coord {
                z_cart_coord = 11.1
            } else if z_cart_coord > 284.5 {
                z_cart_coord = 284.5
            }
        }
    }
}
