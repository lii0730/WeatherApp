//
//  ViewController.swift
//  WeatherApp
//
//  Created by LeeHsss on 2022/01/14.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var userInputTextField: UITextField!
    @IBOutlet weak var loadWeatherButton: UIButton!
    @IBOutlet weak var weatherDataStackView: UIStackView!
    
    @IBOutlet weak var currentCityLabel: UILabel!
    @IBOutlet weak var currentWeatherLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var highTemperatureLabel: UILabel!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func clickWeatherLoadButton(_ sender: UIButton) {
        // Data 불러와서 파싱해주면 되겠네?
        // Data 모델을 정의하는게 낫겟네?
        
        settingUrlSessionAndDataParsing()
    }
    
    private func settingUrlSessionAndDataParsing() {
        
        let config = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: config)
        
        var urlComponents = URLComponents(string: URL.MAIN_URL)
        
        let cityNameQuery = URLQueryItem(name: "q", value: self.userInputTextField.text)
        let appIdQuery = URLQueryItem(name: "appid", value: URL.APPID)
        let unitQuery = URLQueryItem(name: "units", value: "metric")
        
        
        urlComponents?.queryItems?.append(cityNameQuery)
        urlComponents?.queryItems?.append(appIdQuery)
        urlComponents?.queryItems?.append(unitQuery)
        
        guard let requestURL = urlComponents?.url else {
            fatalError("invalid requestURL")
        }
        
        let dataTask = session.dataTask(with: requestURL) { data, response, error in
            guard let responseData = data else { return }
            guard let responseStatus = (response as? HTTPURLResponse)?.statusCode else { return }
            if responseStatus >= 200 && responseStatus < 300 {
                do {
                    let decoder = JSONDecoder()
                    let weatherResponse = try decoder.decode(DataResponseModel.self, from: responseData)
                    self.ParsingData(model: weatherResponse)
                } catch let error {
                    DispatchQueue.main.async {
                        let alert = UIAlertController.init(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        
                        let dismissButton = UIAlertAction(title: "OK", style: .default, handler: { _ in
                        })
                        alert.addAction(dismissButton)
                        self.present(alert, animated: false, completion: nil)
                    }
                }
            } else {
                //MARK: 에러시 alert 표시
                DispatchQueue.main.async {
                    let alert = UIAlertController.init(title: "에러", message: "\(self.userInputTextField.text!)의 날씨를 불러올 수 없습니다.", preferredStyle: .alert)
                    
                    let dismissButton = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    })
                    alert.addAction(dismissButton)
                    self.present(alert, animated: false, completion: nil)
                }
            }
        }
        dataTask.resume()
    }
    
    private func ParsingData(model: DataResponseModel) {
        guard let temp = model.main?.temp else { return }
        guard let temp_min = model.main?.temp_min else { return }
        guard let temp_max = model.main?.temp_max else { return }
        
        DispatchQueue.main.async {
            self.currentCityLabel.text = self.userInputTextField.text
            self.currentWeatherLabel.text = model.weather?.first?.description
            self.currentTemperatureLabel.text = "\(temp) ℃"
            self.minTemperatureLabel.text = "\(temp_min) ℃"
            self.highTemperatureLabel.text = "\(temp_max) ℃"
            self.weatherDataStackView.isHidden = false
        }
    }
}

