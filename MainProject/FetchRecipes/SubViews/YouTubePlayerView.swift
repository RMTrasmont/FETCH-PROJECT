//
//  YoutubePlayer.swift
//  FetchRecipes
//
//  Created by RMT on 4/30/25.
//

import SwiftUI

struct YouTubePlayerView: View {
    @State private var showEmbedView: Bool = true
    @ObservedObject var recipe:Recipe
    
    var vidID: String {
        if recipe.youtubeURL != "No Youtube URL"{
            if let id = extractVideoID(from: recipe.youtubeURL){
                print("Video ID in YoutubePLayerView: \(id)")
                return id
            }
        }
        return "Missing Video ID"
    }
    
    var vidName: String {
        if recipe.name != "No Name"{
            return recipe.name
        }else{
            return "No Name"
        }
    }

    
    var body: some View {
        VStack {
            Text(vidName) // Display video title
                .font(.title)
                .bold()
                .padding()
            
            YoutubeEmbedView(videoTitle:vidName, videoID: vidID, ) // Embed YouTube video
                .frame(height: 250) // Set video frame height
                
            
            Button(action: openYouTubeAppForVideo) { // Button to open video in YouTube app
                Label("Watch on YouTube", systemImage: "play.circle.fill")
                    .foregroundStyle(.blue)
                    .font(.title2)
            }
            
            Spacer()
        }
        .navigationTitle("Playing Video")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear{showEmbedView = false} ///This deinit the view,make new ones each time
    }
    
    // Open video in YouTube app or Safari
    private func openYouTubeAppForVideo() {
        guard let url = URL(string: recipe.youtubeURL) else{
            print("INVALID URL STRING")
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url) // Open in YouTube app if installed
        } else {
            UIApplication.shared.open(url) // Open in Safari if app isn't installed
        }
    }
    
    // Extract vidID from Youtube URl
    func extractVideoID(from url: String) -> String? {
        // Handles typical YouTube watch URL
        if let components = URLComponents(string: url),
           components.host?.contains("youtube.com") == true,
           let queryItems = components.queryItems {
            return queryItems.first(where: { $0.name == "v" })?.value
        }
        return nil
    }

        
 
}

#Preview {
    YouTubePlayerView(recipe:Response.malformedSample[0] )
}


