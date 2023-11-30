//
//  CacheManager.swift
//  Runner
//
//  Created by Ludvig Marcel Carlsen on 28/11/2023.
//

import Foundation


struct CacheManager {
    static let sharedDefaults = UserDefaults.init(suiteName: "group.returwidget")
    
    static func getCachedTripOrFetch(data: FlutterData, completion: @escaping (Result<Response, Error>) -> ()) {
        
        // Return cached trip if fresh
        if let cachedTrip = getCachedTrip() {
            if (cachedTrip.date.isWithin(seconds: 5)) {
                completion(.success(cachedTrip.response))
                return
            }
        }

        // Fetch new trip data
        NetworkManager.getTrip(data: data) { result in
            switch result {
            case .success(let response):
                saveTripToCache(response: response)
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func saveTripToCache(response: Response) {
        do {
            let encoder = JSONEncoder()
            let encodedTrip = try encoder.encode(ResponseCache(date: Date(), response: response))
            sharedDefaults?.set(encodedTrip, forKey: "cached_trip")
            sharedDefaults?.synchronize()
        } catch {
            print("Error encoding to JSON: \(error)")
        }
    }
    
    static func getCachedTrip() -> ResponseCache? {
        guard let data = sharedDefaults?.data(forKey: "cached_trip") else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let cachedTrip = try decoder.decode(ResponseCache.self, from: data)
            return cachedTrip
        } catch {
            print("Error decoding cached trip: \(error)")
            return nil
        }
    }
}
