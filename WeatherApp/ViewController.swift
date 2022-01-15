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
        settingUrlSessionAndDataParsing()
    }
    
    private func settingUrlSessionAndDataParsing() {
        
        //MARK: URLSession Setting
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
        
        // MARK: Data Task
        let dataTask = session.dataTask(with: requestURL) { [weak self] data, response, error in
            guard let self = self else { return }
            guard let responseData = data else { return }
            guard let responseStatus = (response as? HTTPURLResponse)?.statusCode else { return }
            
            let decoder = JSONDecoder()
            do {
                if responseStatus >= 200 && responseStatus < 300 && error == nil {
                    let weatherResponse = try decoder.decode(DataResponseModel.self, from: responseData)
                    
                    //MARK: Parsing Data
                    self.ParsingData(model: weatherResponse)
                } else {
                    //MARK: Display Error Alert
                    let errorMessage = try? decoder.decode(ErrorMessage.self, from: responseData)
                    if let message = errorMessage?.message {
                        self.showAlert(message: message)
                    }
                }
            }
            catch let error {
                
                //MARK: Display Error Alert
                self.showAlert(message: error.localizedDescription)
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
    
    private func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController.init(title: "Error", message: message, preferredStyle: .alert)
            
            let dismissButton = UIAlertAction(title: "OK", style: .default, handler: { _ in
            })
            alert.addAction(dismissButton)
            self.present(alert, animated: false, completion: nil)
        }
    }
}

