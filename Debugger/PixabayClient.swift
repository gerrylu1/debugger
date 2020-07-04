//
//  PixabayClient.swift
//  Debugger
//
//  Created by Gerry Low on 2020-06-26.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import Foundation
import UIKit

class PixabayClient {
    
    static let apiKey = Secret.apiKey
    
    enum EndPoint {
        static let base = "https://pixabay.com/api/"
        static let apiKeyParam = "?key=\(apiKey)"
        static let searchBackgroundPhotos = "&image_type=photo&category=backgrounds"
        
        case searchBackgroundPhotos(page: Int, perPage: Int)
        
        var stringValue: String {
            switch self {
            case let .searchBackgroundPhotos(page, perPage): return EndPoint.base + EndPoint.apiKeyParam + EndPoint.searchBackgroundPhotos + "&per_page=\(perPage)&page=\(page)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func searchBackgroundPhotos(page: Int, perPage: Int, completion: @escaping (ImageSearchResponse?, Error?) -> Void) {
        taskForGETRequest(url: EndPoint.searchBackgroundPhotos(page: page, perPage: perPage).url, responseType: ImageSearchResponse.self) { (responseObject, error) in
            guard let responseObject = responseObject else {
                completion(nil, error)
                return
            }
            completion(responseObject, nil)
        }
    }
    
    @discardableResult class func getImage(imageURL: String, completion: @escaping (UIImage?, Error?) -> Void) -> URLSessionTask? {
        if let url = URL(string: imageURL) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    return
                }
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    completion(image, nil)
                }
            }
            task.resume()
            return task
        } else {
            completion(nil, PixabayClientError.invalidURLError)
            return nil
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> Void {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            parseData(responseType: ResponseType.self, data: data, error: error) { (responseObject, error) in
                DispatchQueue.main.async {
                    completion(responseObject, error)
                }
            }
        }
        task.resume()
    }
    
    class func parseData<ResponseType: Decodable>(responseType: ResponseType.Type, data: Data?, error: Error?, completion: @escaping (ResponseType?, Error?) -> Void) {
        guard let data = data else {
            completion(nil, error)
            return
        }
        do {
            let responseObject = try JSONDecoder().decode(ResponseType.self, from: data)
            completion(responseObject, nil)
        } catch {
            completion(nil, error)
        }
    }
    
}
