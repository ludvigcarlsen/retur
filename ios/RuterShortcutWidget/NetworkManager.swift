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

    
    static func getTrip(data: FlutterData, completion: @escaping (Result<Response, Error>) -> ()) {
        var request = URLRequest(url: URL(string: baseURL)!)
        let query = getQuery(from: data.from, to: data.to, filter: data.filter)
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
    

    private static func getQuery(from: StopPlace, to: StopPlace, filter: Filter) -> String {
        return """
          {
            trip(
              from: {
                place: "\(from.id ?? "")",
                coordinates: {latitude: \(from.latitude), longitude: \(from.longitude)},
                name: "\(from.name)"}
              to: {
                place: "\(to.id ?? "")",
                coordinates: {latitude: \(to.latitude), longitude: \(to.longitude)},
                name: "\(to.name)"}
              filters: \(formatNotFilter(modes: filter.not.transportModes))
              modes: {accessMode: foot, egressMode: foot}
              walkSpeed: \(filter.walkSpeed / 3.6)
            ) {
              tripPatterns {
                expectedStartTime
                expectedEndTime
                legs {
                  mode
                  distance
                  expectedStartTime
                  fromPlace {
                    name
                  }
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
    
    private static func formatNotFilter(modes: Set<TransportMode>) -> String {
        if (modes.isEmpty) { return "{}" }
        let modesString = modes.map { "{transportMode: \($0.rawValue)}" }.joined(separator: ", ")
        return "{not: {transportModes: [\(modesString)]}}"
    }
}
