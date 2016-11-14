//
//  OCVWeatherHourlyCollection.swift
//  OCVSwift
//
//  Created by Eddie Seay on 6/8/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class OCVWeatherHourlyCollection: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {

    var collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
    let dateFormatter = DateFormatter()

    var hourlyWeather: [HourlyForecast] = [] {
        didSet {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "ha"
            collectionView.reloadData()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if hourlyWeather.count >= 24 { return 24 }
        return hourlyWeather.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? OCVHourlyWeatherCell else {
            fatalError("Could not dequeue cell with identifier: \(reuseIdentifier)")
        }
        return configuredHourlyCell(cell, hour: hourlyWeather[(indexPath as NSIndexPath).row])
    }

    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }

    func configuredHourlyCell(_ cell: OCVHourlyWeatherCell, hour: HourlyForecast) -> OCVHourlyWeatherCell {
        cell.timeLabel.text = dateFormatter.string(from: hour.date as Date)
        cell.imageItem.image = UIImage(named: hour.icon)?.withRenderingMode(.alwaysTemplate)
        cell.temperatureLabel.text = "\(Int(round(hour.temperatureF)))º"
        return cell
    }

}
