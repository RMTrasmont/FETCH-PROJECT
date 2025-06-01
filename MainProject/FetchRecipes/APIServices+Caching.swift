//
//  APIServices.swift
//  FetchRecipes
//
//  Created by RMT on 4/29/25.
//

import Foundation


//Protocol for Mocking in Unit Test
protocol APIServicesProtocol {
    func fetchRecipes(for endPoint: String) async throws -> Response
}

//API Service
class APIServices: APIServicesProtocol {
    static let shared:APIServicesProtocol = APIServices()
    private let session: URLSession
    private let cacheManager:MyNSCacheManager
    
    ///Allow dependency injection for UNIT Test.   Real App Code Runs w/ given Default values.
    ///Real App Code Use: APIService.shared  OR APIService()
    ///Unit Test Code Use: APIService(session:mockSession) OR APIService(cacheManager:mockCache)
    init(session:URLSession = .shared, cacheManager:MyNSCacheManager = .shared) {
        self.session = session
        self.cacheManager = cacheManager
        
    }
    
    
    //"ENDPoints"...Also used as unique Keys for Cache
    static let completeEndPoint:String = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
    static let malformedEndPoint:String = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json"
    static let emptyEndPoint:String = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json"
    
    
    func fetchRecipes(for endPoint: String) async throws -> Response {
        
        //---- CHECK IF WE ALREADY CACHED THE DATA & EXIT FUNC ----
        if let cachedResponse = cacheManager.getCachedResponseData(forKey: endPoint) {
            return  cachedResponse
        }
        
        //------IF WE'RE HERE, WE DID NOT CACHE THE DATA YET...-----
        
        guard let endPointURL = URL(string: endPoint) else {
            ///Throw Runtime error
            throw NSError(domain: "*Cannot convert String into URL", code: 1, userInfo: nil)
        }
        
        do {
            let (data,response) = try await session.data(from: endPointURL)
            
            ///Check Valid HTTP Response or Throw runtime Error
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "*Invalid HTTP Response", code: 500, userInfo: nil)
            }
            
            ///Check we have something coming back as response
            if (200...299).contains(httpResponse.statusCode) {
                //print("Data received: \(String(data: data, encoding: .utf8) ?? "No data")")
                let recipesResponse = try JSONDecoder().decode(Response.self, from: data)
                                    //...We Got Data Back
                //*SAVE to Cache using the endpoint* as Key
                cacheManager.cacheResponseData(recipesResponse, forKey: endPoint)
                //Return response Object.
                return recipesResponse
            } else {
                throw NSError(domain: "*HTTP Error*", code: httpResponse.statusCode, userInfo: nil)
            }
            
        } catch {
            print("Error: \(error.localizedDescription)") // Print error description
            throw error
        }
        
    }
    
    
}

//CACHE SERVICE (NSCache)
class MyNSCacheManager{
    private var responseCache = NSCache<NSString, Response>()   // NSCache <Key,Value>
    private var wikiCache = NSCache<NSString, WikiSummary>()
    static let shared = MyNSCacheManager()

    private init() {
        ///Configure Caches
        responseCache.totalCostLimit = 1024 * 1024 * 100  /// 100 MB of memory the cache can use.
        responseCache.countLimit = 100  /// Limit to 100 items is the maximum number of items the cache can hold
        
        wikiCache.totalCostLimit = 1024 * 1024 * 50
        wikiCache.countLimit = 75
        
    }

    //--- FOR HANDLING *RESPONSE-DATA
    func getCachedResponseData(forKey key: String) -> Response? {
        if let cachedResponse = responseCache.object(forKey: key as NSString){
            print("- RESPONSE CACHE HIT: Returning cached data for key \(key)")
            return cachedResponse
        }
        print("- RESPONSE CACHE MISS: No cached data for key \(key)")
        return nil
    }

    func cacheResponseData(_ data: Response, forKey key: String) {
        print("- CACHING RESPONSE DATA FOR KEY: \(key)")
        responseCache.setObject(data, forKey: key as NSString)
    }
    
    //--- FOR HANDLING ADDED *WIKI-DATA (from RecipeDetailView Extension)
    func getCachedWikiData(forKey key: String) -> WikiSummary? {
        if let cachedWikiData = wikiCache.object(forKey: key as NSString){
            print("- WIKI CACHE HIT: Returning cached data for key \(key)")
            return cachedWikiData
        }
        print("- WIKI CACHE MISS: No cached data for key \(key)")
        return nil
    }
    
    func cacheWikiData(_ data: WikiSummary, forKey key: String) {
        print("- CACHING WIKI DATA FOR KEY: \(key)")
        wikiCache.setObject(data, forKey: key as NSString)
    }
    
    //Used in Unit Test (Using NSCache auto-removes data, this just good practice)
    func clearCaches(){
        responseCache.removeAllObjects()
    }
    
    
}





