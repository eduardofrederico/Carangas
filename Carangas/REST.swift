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

enum RESTOperation {
    case save
    case update
    case delete
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
    
    class func loadBrands(onComplete: @escaping ([Brand?]) -> Void) {
        guard let url = URL(string: "https://http://fipeapi.appspot.com/api/1/carros/marcas.json") else {
            onComplete(nil)
            return
        }
        
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?)
            in
            
            if error == nil {
                
                guard let response = response as? HTTPURLResponse else {
                    onComplete(nil)
                    return
                }
                if response.statusCode == 200 {
                    
                    guard let data = data else {return}
                    
                    do {
                        let brands = try JSONDecoder().decode([Brand].self, from: data)
                        onComplete(brands)
                    } catch {
                        print(error.localizedDescription)
                        onComplete(nil)
                    }
                    
                } else {
                    print("Ocorreu algum erro inesperado no servidor.")
                    onComplete(nil)
                }
                
            } else {
                onComplete(nil)
            }
            
        }
        dataTask.resume()
    }
    
    
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
    
    class func save(car: Car, onComplete: @escaping (Bool) -> Void) {
        applyOperation(car: <#T##Car#>, operation: .save, onComplete: onComplete)
    }
    
    class func update(car: Car, onComplete: @escaping (Bool) -> Void) {
        applyOperation(car: <#T##Car#>, operation: .update, onComplete: onComplete)
    }
    
    class func delete(car: Car, onComplete: @escaping (Bool) -> Void) {
        applyOperation(car: <#T##Car#>, operation: .delete, onComplete: onComplete)
    }
    
    
    private class func applyOperation(car: Car, operation: RESTOperation, onComplete: @escaping (Bool) -> Void) {
        
        let urlString = basePath + "/" + (car._id! ?? "")
        
        guard let url = URL(string: urlString) else {
            onComplete(false)
            return
        }
        
        var httpMethod: String = ""
        var request = URLRequest(url: url)
        
        switch operation {
            case .save:
                httpMethod = "POST"
            case .update:
                httpMethod = "PUT"
            case .delete:
                httpMethod = "DELETE"
        }
        
        request.httpMethod = httpMethod
        guard let json = try? JSONEncoder().encode(car) else {
            onComplete(false)
            return
        }
        
        request.httpBody = json
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                guard let response = response as? HTTPURLResponse, response.statusCode == 200, let data = data else {
                    onComplete(false)
                    return
                }
                onComplete(true)
            } else {
                onComplete(false)
            }
        }
        dataTask.resume()
    }
    
}
