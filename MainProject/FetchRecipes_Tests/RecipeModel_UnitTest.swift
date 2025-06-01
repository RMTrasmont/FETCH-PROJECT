//
//  RecipeModel_UnitTest.swift
//  FetchRecipes_Tests
//
//  Created by RMT on 5/18/25.
//

import XCTest
@testable import FetchRecipes

final class RecipeModel_UnitTest: XCTestCase {
    
    ///'Response.init(recipes) - Test The memberwise Initializer w/ Values
    func test_Response_Init_WithValues(){
        let mockRecipe = Recipe(
            cuisine: "Mock Cuisine",
            name: "Mock Name",
            photoURLLarge: "Mock URL Large",
            photoURLSmall: "Mock URL Small",
            sourceURL: "Mock source URL",
            uuid: "12345",
            youtubeURL: "Mock Youtube URL"
        )
        
        let response = Response(recipes: [mockRecipe])
        
        XCTAssertEqual(response.recipes.count, 1)
        XCTAssert(response.recipes.first?.name == "Mock Name")
        XCTAssert(response.recipes.first?.cuisine == "Mock Cuisine")
        XCTAssert(response.recipes.first?.photoURLLarge == "Mock URL Large")
        XCTAssert(response.recipes.first?.photoURLSmall == "Mock URL Small")
        XCTAssert(response.recipes.first?.sourceURL == "Mock source URL")
        XCTAssert(response.recipes.first?.uuid == "12345")
        XCTAssert(response.recipes.first?.youtubeURL == "Mock Youtube URL")
        
    }
    
    ///'Response.init(recipes) - Test The memberwise Initializer w/ No Values
    func test_Response_Init_WithMissingValues(){
        let mockRecipe = Recipe(
            cuisine: nil,
            name: nil,
            photoURLLarge: nil,
            photoURLSmall: nil,
            sourceURL: nil,
            uuid: nil,
            youtubeURL: nil
        )
        
        let response = Response(recipes: [mockRecipe])
        
        //Value should Fallback to default
        XCTAssertEqual(response.recipes.count, 1)
        XCTAssert(response.recipes.first?.name == "No Name")
        XCTAssert(response.recipes.first?.cuisine == "No Cuisine")
        XCTAssert(response.recipes.first?.photoURLLarge == "No Large Photo URL")
        XCTAssert(response.recipes.first?.photoURLSmall == "No Small Photo URL")
        XCTAssert(response.recipes.first?.sourceURL == "No Source URL")
        XCTAssert(response.recipes.first?.uuid.isEmpty == false) //Always make a UUID if missing
        XCTAssert(response.recipes.first?.youtubeURL == "No Youtube URL")
        
    }
    
    /// Test init from decoder with Values AND No Values
    func test_Recipe_Decoding_WithFullJSON() throws {
        
        let jsonData = """
            {
                        "cuisine": "American",
                        "name": "Cheese Burger",
                        "photo_url_large": "https://example.com/large.jpg",
                        "photo_url_small": "https://example.com/small.jpg",
                        "source_url": "https://example.com",
                        "uuid": "12345",
                        "youtube_url": "https://youtube.com/video"
                    }
            """.data(using: .utf8)
        
        let decoder = JSONDecoder()
        let recipe = try decoder.decode(Recipe.self, from: jsonData!)
        
        XCTAssert(recipe.cuisine == "American", "Decoded Cuisine sould be 'American' ")
        XCTAssert(recipe.name == "Cheese Burger", "Decoded Cuisine sould be 'Cheese Burger' ")
        XCTAssertEqual(recipe.photoURLLarge, "https://example.com/large.jpg")
        XCTAssertEqual(recipe.photoURLSmall, "https://example.com/small.jpg")
        XCTAssertEqual(recipe.sourceURL,"https://example.com")
        XCTAssert(recipe.uuid == "12345", "Decoded UUID sould be '12345' ")
        XCTAssertEqual(recipe.youtubeURL, "https://youtube.com/video" )
        XCTAssertEqual(recipe.isFavorite, false, "New recipes should not be favorites by default")
        
    }
    
    /// Test init from decoder with No Values
    func test_Recipe_Decoding_WithMissingOrNullValues() throws {
        let json = """
            {
                
                "name": "Apple Pie",
                "photo_url_large": "https://example.com/large.jpg",
                "photo_url_small": null,
                "source_url": "",
                "uuid": "98765",
                "youtube_url": "https://youtube.com/video"
            }
            """.data(using: .utf8)!
        
        let recipe = try JSONDecoder().decode(Recipe.self, from: json)
        
        XCTAssertEqual(recipe.cuisine, "No Cuisine", "Missing cuisine-key/value should default to  'cuisine: No Cuisine' ")
        XCTAssertEqual(recipe.name, "Apple Pie")
        XCTAssert(recipe.photoURLLarge == "https://example.com/large.jpg")
        XCTAssertEqual(recipe.photoURLSmall, "No Small Photo URL", "Null photoURLSmall should default to 'No Small Photo URL' ")
        XCTAssertEqual(recipe.sourceURL, "No Source URL", "Empty sourceURL should default to 'No Source URL' ")
        XCTAssert(recipe.youtubeURL == "https://youtube.com/video")
        XCTAssert(recipe.uuid == "98765")
        XCTAssertEqual(recipe.isFavorite, false, "New recipes should not be favorites by default")
    }
    
    func test_Recipe_Init_WithDefaultValues() throws {
        let json = """
            {
                
                "name": null,
                "photo_url_large":null,
                "photo_url_small": null,
                "source_url": "",
                "uuid": null,
                "youtube_url": ""
            }
            """.data(using: .utf8)!
        
            let recipeDefaultValues = try JSONDecoder().decode(Recipe.self, from: json)

            XCTAssertEqual(recipeDefaultValues.name, "No Name")
            XCTAssertEqual(recipeDefaultValues.cuisine, "No Cuisine")
            XCTAssertEqual(recipeDefaultValues.photoURLLarge, "No Large Photo URL")
            XCTAssertEqual(recipeDefaultValues.photoURLSmall, "No Small Photo URL")
            XCTAssertEqual(recipeDefaultValues.sourceURL, "No Source URL")
            XCTAssertEqual(recipeDefaultValues.youtubeURL, "No Youtube URL")
            XCTAssert(recipeDefaultValues.uuid.isEmpty == false, "UUID Should never be empty, If missing a new one is created")
            XCTAssertEqual(recipeDefaultValues.isFavorite, false, "New recipes should not be favorites by default")
        }
    

}


//MARK: - WikiSummary Test
    
    
final class WikiSummaryTests: XCTestCase {
    
    /// WikiSummary.init(from:) - Test the Initialized Object from Decoder
    func test_DecodingWikiSummary_FromJSON() throws {
        let json = """
            {
                "title": "Chocolate Cake",
                "description": "Brief explanation about choco cake",
                "extract": "Long and detaield explanation about what chocolate cake is etc..."
            }
            """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let summary = try decoder.decode(WikiSummary.self, from: json)
        
        XCTAssert(summary.title == "Chocolate Cake")
        XCTAssert(summary.description == "Brief explanation about choco cake")
        XCTAssert(summary.extract == "Long and detaield explanation about what chocolate cake is etc...")
    }
    
    func test_DecodingWikiSummary_WithNullValues() throws {
        let json = """
            {
                "title": null,
                "description": null,
                "extract": null
            }
            """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let summary = try decoder.decode(WikiSummary.self, from: json)
        
        XCTAssert(summary.title == "No Wiki Title")
        XCTAssert(summary.description == "No Wiki Description")
        XCTAssert(summary.extract == "No Wiki Summary")
    }
    
    ///"WikiSummary.init(title: description:extract:)" - Test the Memberwise Initializer
    func test_WikiMemberwiseInitializer() {
        let summary = WikiSummary(title: "Chocolate Cake",
                                  description: "Brief explanation about choco cake",
                                  extract: "Long and detaield explanation about what chocolate cake is etc...")
        
        XCTAssert(summary.title == "Chocolate Cake")
        XCTAssert(summary.description == "Brief explanation about choco cake")
        XCTAssert(summary.extract == "Long and detaield explanation about what chocolate cake is etc...")
    }
    
    
}

