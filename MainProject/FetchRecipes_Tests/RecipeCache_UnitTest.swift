//
//  RecipeCache_UnitTest.swift
//  FetchRecipes_Tests
//
//  Created by RMT on 5/18/25.
//

import XCTest
@testable import FetchRecipes

final class RecipeCache_UnitTest: XCTestCase {

    var cacheManager:MyNSCacheManager!
    var mockResponse:Response!
    
    override func setUp() {
        super.setUp()
        cacheManager = MyNSCacheManager.shared
        cacheManager.clearCaches()
        
        /// Create mock data
        let recipe = Recipe(
            cuisine: "Test Cuisine",
            name: "Test Name",
            photoURLLarge: "large.jpg",
            photoURLSmall: "small.jpg",
            sourceURL: "source.com",
            uuid: "12345",
            youtubeURL: "youtube.com"
        )
        
        mockResponse = Response(recipes: [recipe])
    }
    
    override func tearDown() {
        /// Clear all cached data (reinit NSCache)
        super.tearDown()
        MyNSCacheManager.shared.clearCaches()
    }
    
    func test_CacheAndRetrieveResponseSuccessful() {
        let key = "testKey"
        ///Cashe the item
        cacheManager.cacheResponseData(mockResponse, forKey: key)
        ///Fetch the Cached Item
        let cached = cacheManager.getCachedResponseData(forKey: key)
        
        ///Test the Cached item
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.recipes.first?.cuisine, "Test Cuisine")
        XCTAssertEqual(cached?.recipes.first?.name, "Test Name")
        XCTAssertEqual(cached?.recipes.first?.photoURLLarge, "large.jpg")
        XCTAssertEqual(cached?.recipes.first?.photoURLSmall, "small.jpg")
        XCTAssertEqual(cached?.recipes.first?.sourceURL, "source.com")
        XCTAssertEqual(cached?.recipes.first?.uuid, "12345")
        XCTAssertEqual(cached?.recipes.first?.youtubeURL, "youtube.com")
    }
    
    func test_CacheAndRetrieveResponseMiss(){
        let key = "no-Value-key"
        //Skipped the Caching Part...Directly Fetch from cache
        let cached = cacheManager.getCachedResponseData(forKey: key)
        XCTAssertNil(cached, "* cache should be nil, because no value was purposely cached for this key")
    }
    
    func test_CacheCanOverritePreviousData(){
        let key = "overrideKey"
        
        ///First Object to cache
        let firstRecipe = Recipe(
            cuisine: "First Test Cuisine",
            name: "First Test Name",
            photoURLLarge: "First large.jpg",
            photoURLSmall: "First small.jpg",
            sourceURL: "First source.com",
            uuid: "12345",
            youtubeURL: "First youtube.com"
        )
        let mockResponseOne = Response(recipes: [firstRecipe])
    
        ///Second Object to cache
        let secondRecipe = Recipe(
            cuisine: "Second Test Cuisine",
            name: "Second Test Name",
            photoURLLarge: "Second large.jpg",
            photoURLSmall: "Second small.jpg",
            sourceURL: "Second source.com",
            uuid: "98765",
            youtubeURL: "Second youtube.com"
        )
        let mockResponseTwo = Response(recipes: [secondRecipe])
        
        //Caching First item
        cacheManager.cacheResponseData(mockResponseOne, forKey: key)
        //Testing First Item
        let firstCached = cacheManager.getCachedResponseData(forKey: key)
        XCTAssertNotNil(firstCached, "* firstCached should not be nil, because value was cached for this key")
        XCTAssert(firstCached?.recipes.first?.name == "First Test Name")
        XCTAssert(firstCached?.recipes.first?.cuisine == "First Test Cuisine")
        XCTAssert(firstCached?.recipes.first?.photoURLLarge == "First large.jpg")
        XCTAssert(firstCached?.recipes.first?.photoURLSmall == "First small.jpg")
        XCTAssert(firstCached?.recipes.first?.sourceURL == "First source.com")
        XCTAssert(firstCached?.recipes.first?.uuid == "12345")
        XCTAssert(firstCached?.recipes.first?.youtubeURL == "First youtube.com")
        
        //Caching Second item
        cacheManager.cacheResponseData(mockResponseTwo, forKey: key)
        //Testing Second Item has overrrided the first item.
        let secondCached = cacheManager.getCachedResponseData(forKey: key)
        XCTAssertNotNil(secondCached, "* secondCached should not be nil, because value was cached for this key")
        XCTAssert(secondCached?.recipes.first?.name == "Second Test Name")
        XCTAssert(secondCached?.recipes.first?.cuisine == "Second Test Cuisine")
        XCTAssert(secondCached?.recipes.first?.photoURLLarge == "Second large.jpg")
        XCTAssert(secondCached?.recipes.first?.photoURLSmall == "Second small.jpg")
        XCTAssert(secondCached?.recipes.first?.sourceURL == "Second source.com")
        XCTAssert(secondCached?.recipes.first?.uuid == "98765")
        XCTAssert(secondCached?.recipes.first?.youtubeURL == "Second youtube.com")
        
    }
    
    func test_CacheAndRetrieveWikiDataSuccessful() {
        let key = "wikiKey"
        
        let mockWiki = WikiSummary(
            title: "Mock Title",
            description: "Mock Description",
            extract: "Mock Summary"
        )
        
        // Cache the wiki data
        cacheManager.cacheWikiData(mockWiki, forKey: key)
        // Retrieve from cache
        let cachedWiki = cacheManager.getCachedWikiData(forKey: key)
        
        XCTAssertNotNil(cachedWiki)
        XCTAssertEqual(cachedWiki?.title, "Mock Title")
        XCTAssertEqual(cachedWiki?.description, "Mock Description")
        XCTAssertEqual(cachedWiki?.extract, "Mock Summary")
    }
    
    func test_CacheMissForWikiDataReturnsNil() {
        let key = "nonexistentWikiKey"
        //Fetch using key for item that was never cached
        let cachedWiki = cacheManager.getCachedWikiData(forKey: key)
        
        XCTAssertNil(cachedWiki, "* Expected nil because no wiki data was cached for key \(key)")
    }
    
    func text_clearingCache(){
        let key = "wikiKey"
        
        let mockWiki = WikiSummary(
            title: "Mock Title",
            description: "Mock Description",
            extract: "Mock Summary"
        )
        
        // Cache the wiki data
        cacheManager.cacheWikiData(mockWiki, forKey: key)
        // Retrieve from cache
        let cachedWiki = cacheManager.getCachedWikiData(forKey: key)
        //Check Item Exists
        XCTAssertNotNil(cachedWiki)
        XCTAssertEqual(cachedWiki?.title, "Mock Title")
        XCTAssertEqual(cachedWiki?.description, "Mock Description")
        XCTAssertEqual(cachedWiki?.extract, "Mock Summary")
        
        //Clear cache
        cacheManager.clearCaches()
        // Retrieve from cache
        let clearCachedWiki = cacheManager.getCachedWikiData(forKey: key)
        //Check Item No longer Exists
        XCTAssertNil(clearCachedWiki)
        XCTAssertEqual(clearCachedWiki?.title, "No Wiki Title")
        XCTAssertEqual(clearCachedWiki?.description, "No Wiki Description")
        XCTAssertEqual(clearCachedWiki?.extract, "No Wiki Summary")
        
    }
    

}
