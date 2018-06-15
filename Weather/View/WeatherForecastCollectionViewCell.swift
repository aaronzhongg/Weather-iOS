//
//  WeatherForecastCollectionViewCell.swift
//  Weather
//
//  Created by Aaron Zhong on 14/06/18.
//  Copyright © 2018 Aaron Zhong. All rights reserved.
//

import UIKit

class WeatherForecastCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
