//
//  Recipes.swift
//  FetchRecipes
//
//  Created by RMT on 4/29/25.
//

import Foundation

class Response: Codable {
    let recipes: [Recipe]
    
    init(recipes: [Recipe]) {
        self.recipes = recipes
    }
}

class Recipe:Codable, Identifiable,ObservableObject {
    @Published var isFavorite: Bool = false  //<-- Converted Model to Class b/c we're binding this
    let id = UUID()
    let cuisine: String
    let name: String
    let photoURLLarge: String
    let photoURLSmall: String
    let sourceURL: String
    let uuid: String
    let youtubeURL: String
    
    
    enum CodingKeys:String, CodingKey {
        case cuisine
        case name
        case photoURLLarge = "photo_url_large"
        case photoURLSmall = "photo_url_small"
        case sourceURL = "source_url"
        case uuid
        case youtubeURL = "youtube_url"
    }
    
    //  Custom init to Handle Optional Values & Missing API Keys *when Decoding
    required init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        //Decode Optional Values
        self.cuisine = try container.decodeIfPresent(String.self, forKey: .cuisine) ?? "No Cuisine"
        self.photoURLLarge = try container.decodeIfPresent(String.self, forKey: .photoURLLarge) ?? "No Large Photo URL"
        self.photoURLSmall = try container.decodeIfPresent(String.self, forKey: .photoURLSmall) ?? "No Small Photo URL"
        self.uuid = try container.decodeIfPresent(String.self, forKey: .uuid) ?? UUID().uuidString //<--- Never Empty
        
        //Decode for Missing API-Key-Value pairs
        let apiName = try container.decodeIfPresent(String.self, forKey: .name)
        self.name = (apiName?.isEmpty == false) ? apiName! : "No Name"
        
        let apiYouTubeURL = try container.decodeIfPresent(String.self, forKey: .youtubeURL)
        self.youtubeURL = (apiYouTubeURL?.isEmpty == false) ? apiYouTubeURL! : "No Youtube URL"  //<--- Add Name of cuisine for query
        
        let apiSourceURL = try container.decodeIfPresent(String.self, forKey: .sourceURL)
        self.sourceURL = (apiSourceURL?.isEmpty == false) ? apiSourceURL! : "No Source URL"  //<--- Add Name of cuisine for query
        
    }
    
    // Manual Memberwise Init (since we have a custom init above,Swift no longer synthesizes the memberwise initializer for you automatically)
        init(
            cuisine: String?,
            name: String?,
            photoURLLarge: String?,
            photoURLSmall: String?,
            sourceURL: String?,
            uuid: String?,
            youtubeURL: String?
        ) {
            self.cuisine = cuisine ?? "No Cuisine"
            self.name = (name?.isEmpty == false) ? name! : "No Name"
            self.photoURLLarge = photoURLLarge ?? "No Large Photo URL"
            self.photoURLSmall = photoURLSmall ?? "No Small Photo URL"
            self.sourceURL = (sourceURL?.isEmpty == false) ? sourceURL! : "No Source URL"
            self.uuid = uuid ?? UUID().uuidString // Never Empty
            self.youtubeURL = (youtubeURL?.isEmpty == false) ? youtubeURL! : "No Youtube URL"
        }

}

//USE SAMPLE FOR BUILDING & PREVIEW & TESTS
extension Response {
    
    static let completeSample: [Recipe] = [
        Recipe(
            cuisine: "Malaysian",
            name: "Apam Balik",
            photoURLLarge: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
            photoURLSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
            sourceURL: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
            uuid: "0c6ca6e7-e32a-4053-b824-1dbf749910d8",
            youtubeURL: "https://www.youtube.com/watch?v=6R8ffRRJcrg"
        ),
        Recipe(
            cuisine: "British",
            name: "Apple & Blackberry Crumble",
            photoURLLarge: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/large.jpg",
            photoURLSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/small.jpg",
            sourceURL: "https://www.bbcgoodfood.com/recipes/778642/apple-and-blackberry-crumble",
            uuid: "599344f4-3c5c-4cca-b914-2210e3b3312f",
            youtubeURL: "https://www.youtube.com/watch?v=4vhcOwVBDO4"
        ),
        Recipe(
            cuisine: "British",
            name: "Apple Frangipan Tart",
            photoURLLarge: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/7276e9f9-02a2-47a0-8d70-d91bdb149e9e/large.jpg",
            photoURLSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/7276e9f9-02a2-47a0-8d70-d91bdb149e9e/small.jpg",
            sourceURL: "https://www.bbcgoodfood.com/recipes/778642/apple-and-blackberry-crumble",
            uuid: "74f6d4eb-da50-4901-94d1-deae2d8af1d1",
            youtubeURL: "https://www.youtube.com/watch?v=rp8Slv4INLk"
        )
    ]
    
    //Missing "name", "youtubeURL", "sourceURL" in Someitems(British)
    static let malformedSample: [Recipe] = [
        Recipe(
            cuisine: "Malaysian",
            name: "Apam Balik",
            photoURLLarge: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
            photoURLSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
            sourceURL: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
            uuid: "0c6ca6e7-e32a-4053-b824-1dbf749910d8",
            youtubeURL: "https://www.youtube.com/watch?v=6R8ffRRJcrg"
        ),
        Recipe(
            cuisine: "British",
            name: nil,
            photoURLLarge: nil /*"https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/large.jpg"*/,
            photoURLSmall:nil /*"https://d3jbb8n5wk0qxi.cloudfront.net/photos/535dfe4e-5d61-4db6-ba8f-7a27b1214f5d/small.jpg"*/,
            sourceURL: nil,
            uuid: "599344f4-3c5c-4cca-b914-2210e3b3312f",
            youtubeURL: nil
        ),
        Recipe(
            cuisine: "British",
            name: "Apple Frangipan Tart",
            photoURLLarge: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/7276e9f9-02a2-47a0-8d70-d91bdb149e9e/large.jpg",
            photoURLSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/7276e9f9-02a2-47a0-8d70-d91bdb149e9e/small.jpg",
            sourceURL: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
            uuid: "74f6d4eb-da50-4901-94d1-deae2d8af1d1",
            youtubeURL: "https://www.youtube.com/watch?v=rp8Slv4INLk"
        )
    ]
    
    static let emptySample:[Recipe] = []
    
    
}


//ADDED EXTRA WIKI RESPONSES FOR FOOD ITEMS.
class WikiSummary:Codable{
    let title:String
    let description:String?
    let extract:String  //<--(summary)
    
    // Custom decoding logic to safely unwrap and provide defaults so you don;t have to unwrap again in the Views
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? "No Wiki Title"
        self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? "No Wiki Description"
        self.extract = try container.decodeIfPresent(String.self, forKey: .extract) ?? "No Wiki Summary"
    }
    
    // Required if you unwrap and provide default values above
        enum CodingKeys: String, CodingKey {
            case title
            case description
            case extract
        }
    
    // Custom memberwise init (for test/mock data) for use w/ "static let sampleWikiResponse"
        init(title: String, description: String, extract: String) {
            self.title = title
            self.description = description
            self.extract = extract
        }

}//END WIKI SUMMARY
