//
//  REST.swift
//  Carangas
//
//  Created by Eduardo Frederico on 13/11/24.
//  Copyright © 2024 Eric Brito. All rights reserved.
//

import Foundation

enum CarsError: Error {
    case url
    case taskError(error: Error)
    case noResponse
    case noData
    case responseStatusCode(code: Int)
    case invalidJSON
}

class REST {
    
    
    private static let basePath = "https://carangas.herokuapp.com/cars"
    
    private static let configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = false
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        config.timeoutIntervalForRequest = 30.0
        config.httpMaximumConnectionsPerHost = 5
        return config
    }()
    
    private static let session = URLSession(configuration: configuration)  //URLSession.shared
    
    class func loadCars(onComplete: @escaping ([Car]) -> Void, onError: @escaping (Error) -> Void) {
        guard let url = URL(string: basePath) else {
            onError(CarsError.url)
            return
        }
        
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?)
            in
            
            if error == nil {
                
                guard let response = response as? HTTPURLResponse else {
                    onError(CarsError.noResponse)
                    return
                }
                if response.statusCode == 200 {
                    
                    guard let data = data else {return}
                    
                    do {
                        let cars = try JSONDecoder().decode([Car].self, from: data)
                        onComplete(cars)
                    } catch {
                        print(error.localizedDescription)
                        onError(CarsError.invalidJSON)
                    }
                    
                } else {
                    print("Ocorreu algum erro inesperado no servidor.")
                    onError(CarsError.responseStatusCode(code: response.statusCode))
                }
                
            } else {
                onError(CarsError.taskError(error: error!))
            }
            
        }
        dataTask.resume()
    }
    
}
