//
//  DataResponseModel.swift
//  WeatherApp
//
//  Created by LeeHsss on 2022/01/15.
//

import Foundation

struct DataResponseModel: Decodable {
    let weather: [Weather]?
    let main: Main?
}

struct Weather: Decodable {
    let main: String?
    let description: String?
}

struct Main: Decodable {
    let temp: Double?
    let temp_min: Double?
    let temp_max: Double?
}
