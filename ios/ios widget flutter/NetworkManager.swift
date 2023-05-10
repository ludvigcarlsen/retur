//
//  NetworkManager.swift
//  Runner
//
//  Created by Ludvig Marcel Carlsen on 10/05/2023.
//

import Foundation

private struct Payload: Codable {
    var variables: String = "{}"
    var query: String
}

final class NetworkManager {
    
    private static var baseURL = "https://api.entur.io/journey-planner/v3/graphql"

    
    static func getTrip(completion: @escaping (Result<Response, Error>) -> ()) {
        var request = URLRequest(url: URL(string: baseURL)!)
        let query = getQuery(from: "NSR:StopPlace:58366", to: "NSR:StopPlace:385")
        let payload = Payload(query: query)

        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("ludvigcarlsen-retur", forHTTPHeaderField: "ET-Client-Name")
        request.httpBody = try! JSONEncoder().encode(payload)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    completion(.failure(error!))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(Response.self, from: data)
                    completion(.success(response))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
        task.resume()
    }
    
    
    private static func getQuery(from: String, to: String) -> String {
        return """
            {
              trip(from: {place: "\(from)"}, to: {place: "\(to)"}) {
                tripPatterns {
                  expectedStartTime
                  expectedEndTime
                  legs {
                    mode
                    distance
                    line {
                      id
                      publicCode
                    }
                  }
                }
                fromPlace {
                  name
                }
                toPlace {
                  name
                }
              }
            }
        """
    }
}
