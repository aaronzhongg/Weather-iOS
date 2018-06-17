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

class WeatherViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let WEATHER_API_URL = "http://api.openweathermap.org/data/2.5/weather"
    let FORECAST_API_URL = "http://api.openweathermap.org/data/2.5/forecast"
    let APP_ID = "22252b5384b9eb32db93dfd00bb03a0c"
    
    let locationManager = CLLocationManager()
    
    var weather: Weather?
    var weatherForecast = [Weather]()
    
    var contrastColour: UIColor?
    
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var weatherForecastCollectionView: UICollectionView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempMinLabel: UILabel!
    @IBOutlet weak var tempMaxLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        weatherForecastCollectionView.delegate = self
        weatherForecastCollectionView.dataSource = self
        
        weatherForecastCollectionView.register(UINib(nibName: "WeatherForecastCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WeatherForecastCell")
        
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = true
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        scrollView.addSubview(refreshControl)
    }
    
    @objc func refresh() {
        weather = nil
        weatherForecast = [Weather]()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        refreshControl.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        
        if location.horizontalAccuracy > 0 {
            print("FOUND LOCATION")
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            let params: [String: String] = ["lon": String(location.coordinate.longitude), "lat": String(location.coordinate.latitude), "appid": APP_ID, "units": "metric" ]
            getCurrentWeatherData(with: params)
            getWeatherForecast(with: params)
        }
    }
    
    // MARK: - Network
    
    func getCurrentWeatherData(with parameters: [String: String]) {
        
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
    
    func getWeatherForecast(with parameters: [String:String]) {
        Alamofire.request(FORECAST_API_URL, method: .get, parameters: parameters).responseData { (response) in
            if let responseData = response.data {
                do {
                    let weatherData = try JSON(data: responseData)
                    
                    // Take up to 10 entries
                    
                    for index in 0...10 {
                        let newForecast = Weather()
                        newForecast.condition = weatherData["list"][index]["weather"][0]["id"].intValue
                        newForecast.weather = weatherData["list"][index]["weather"][0]["main"].stringValue
                        newForecast.temp = weatherData["list"][index]["main"]["temp"].intValue
                        newForecast.date = Date(timeIntervalSince1970: TimeInterval(weatherData["list"][index]["dt"].intValue))
                        self.weatherForecast.append(newForecast)
                    }
                    
                    self.weatherForecastCollectionView.reloadData()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    // MARK: - Update view
    
    func updateView() {
        
        // sunny: flatYellow(), flatOrange()
        // light_rain, shower: flatBlue(), flatNavyBlue()
        // snow4, snow5, overcast, fog: flatWhite, flatGray()
        // cloudy2: flatSkyBly(), flatWhite()
        // tstorm1, tstorm3: flatNavyBlue(), flatBlueColorDark()
        
        if let weatherInfo = self.weather {
            tempLabel.text = "\(weatherInfo.temp)°"
            tempMinLabel.text = "\(weatherInfo.tempMin)°"
            tempMaxLabel.text = "\(weatherInfo.tempMax)°"
            weatherLabel.text = "\(weatherInfo.weather), today in \(weatherInfo.name)"
            
            weatherImageView.image = UIImage(named: weatherInfo.updateWeatherIcon(condition: weatherInfo.condition))
            
            let bgColour = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame: self.view.frame, andColors: weatherInfo.updateBackgroundColor(condition: weatherInfo.condition))
            contrastColour = UIColor(contrastingBlackOrWhiteColorOn: bgColour, isFlat:true)
            
            tempLabel.textColor = contrastColour
            tempMinLabel.textColor = contrastColour
            tempMaxLabel.textColor = contrastColour
            weatherLabel.textColor = contrastColour
            self.view.backgroundColor = bgColour
            
            weatherImageView.image = weatherImageView.image?.withRenderingMode(.alwaysTemplate)
            weatherImageView.tintColor = contrastColour
        }
    }
    
    // MARK: - Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherForecast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherForecastCell", for: indexPath) as! WeatherForecastCollectionViewCell
        cell.tempLabel.text = String(weatherForecast[indexPath.row].temp) + "°"
        cell.weatherImageView.image = UIImage(named: weatherForecast[indexPath.row].updateWeatherIcon(condition: weatherForecast[indexPath.row].condition))
        
        guard let forecastDateTime = weatherForecast[indexPath.row].date else { fatalError() }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ha dd/MM"
        cell.dateTimeLabel.text = dateFormatter.string(from: forecastDateTime)
        
        // Set colour
        cell.tempLabel.textColor = contrastColour
        cell.weatherImageView.image = weatherImageView.image?.withRenderingMode(.alwaysTemplate)
        cell.weatherImageView.tintColor = contrastColour
        cell.dateTimeLabel.textColor = contrastColour
        
        return cell
    }
    
    // MARK: - Collection View Flow Layout Delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(100), height: CGFloat(120))
    }

    
}

