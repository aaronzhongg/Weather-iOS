//
//  Weather.swift
//  Weather
//
//  Created by Aaron Zhong on 13/06/18.
//  Copyright © 2018 Aaron Zhong. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

class Weather {
    var name: String = ""
    var tempMin: Int = 0
    var tempMax: Int = 0
    var temp: Int = 0
    var weather: String = ""
    var condition: Int = 0
    var date: Date?
    
    func updateWeatherIcon(condition: Int) -> String {
        
        switch (condition) {
            
        case 0...300 :
            return "tstorm1"
            
        case 301...500 :
            return "light_rain"
            
        case 501...600 :
            return "shower3"
            
        case 601...700 :
            return "snow4"
            
        case 701...771 :
            return "fog"
            
        case 772...799 :
            return "tstorm3"
            
        case 800 :
            return "sunny"
            
        case 801...804 :
            return "cloudy2"
            
        case 900...903, 905...1000  :
            return "tstorm3"
            
        case 903 :
            return "snow5"
            
        case 904 :
            return "sunny"
            
        default :
            return "dunno"
        }
        
    }
    
    func updateBackgroundColor(condition: Int) -> [UIColor] {
        switch (condition) {
        case 0...300, 900...903, 905...1000:
            return [UIColor.flatNavyBlue(), UIColor.flatBlueColorDark()]
        case 301...500, 501...600:
            return [UIColor.flatBlue(), UIColor.flatNavyBlue()]
        case 601...700, 903, 701...771:
            return [UIColor.flatWhite(), UIColor.flatGray()]
        case 801...804 :
            return [UIColor.flatSkyBlue(), UIColor.flatWhite()]
        case 800, 904 :
            return [UIColor.flatYellow(), UIColor.flatOrange()]
        default :
            return [UIColor.flatSkyBlue(), UIColor.flatBlueColorDark()]
        }
    }
    
}
