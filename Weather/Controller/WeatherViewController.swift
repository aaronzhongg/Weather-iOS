//
//  ViewController.swift
//  Weather
//
//  Created by Aaron Zhong on 13/06/18.
//  Copyright © 2018 Aaron Zhong. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import ChameleonFramework

class WeatherViewController: UIViewController, CLLocationManagerDelegate {

    let WEATHER_API_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "22252b5384b9eb32db93dfd00bb03a0c"
    
    let locationManager = CLLocationManager()
    
    var weather: Weather?
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempMinLabel: UILabel!
    @IBOutlet weak var tempMaxLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            let params: [String: String] = ["lon": String(location.coordinate.longitude), "lat": String(location.coordinate.latitude), "appid": APP_ID, "units": "metric" ]
            
            getCurrentWeatherData(with: params)
        }
    }
    
    // MARK: - Network
    
    func getCurrentWeatherData(with parameters: [String: String]) {
        print(parameters)
        
        Alamofire.request(WEATHER_API_URL, method: .get, parameters: parameters).responseData { (response) in
            if let responseData = response.data {
                do {
                    let weatherData = try JSON(data: responseData)
                    
                    let newWeatherInfo = Weather()
                    newWeatherInfo.name = weatherData["name"].stringValue
                    newWeatherInfo.temp = weatherData["main"]["temp"].intValue
                    newWeatherInfo.tempMin = weatherData["main"]["temp_min"].intValue
                    newWeatherInfo.tempMax = weatherData["main"]["temp_max"].intValue
                    newWeatherInfo.weather = weatherData["weather"][0]["main"].stringValue
                    newWeatherInfo.condition = weatherData["weather"][0]["id"].intValue
                    
                    self.weather = newWeatherInfo
                    
                    self.updateView()
                } catch {
                    print(error)
                }
                
            }
        }
    }
    
    // MARK: - Update view
    
    func updateView() {
        if let weatherInfo = self.weather {
            tempLabel.text = "\(weatherInfo.temp)°"
            tempMinLabel.text = "\(weatherInfo.tempMin)°"
            tempMaxLabel.text = "\(weatherInfo.tempMax)°"
            weatherLabel.text = "\(weatherInfo.weather), today in \(weatherInfo.name)"
            
            weatherImageView.image = UIImage(named: weatherInfo.updateWeatherIcon(condition: weatherInfo.condition))
            
            tempLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn: UIColor.flatOrange(), isFlat:true)
            self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors: [UIColor.flatYellow(), UIColor.flatOrange()])
            
            weatherImageView.image = weatherImageView.image?.withRenderingMode(.alwaysTemplate)
            weatherImageView.tintColor = .white
        }
    }
}

