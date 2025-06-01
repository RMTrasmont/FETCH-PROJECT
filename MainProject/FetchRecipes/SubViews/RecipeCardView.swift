//
//  RecipeCardView.swift
//  FetchRecipes
//
//  Created by RMT on 4/29/25.
//

import Foundation
import SwiftUI

struct RecipeCardView: View {
    @ObservedObject var recipe:Recipe
    
    var body: some View {
        VStack(alignment:.center){
            
            ZStack{
                //IMAGE
                AsyncImage(url: URL(string:recipe.photoURLSmall)) { phase in
                    if let image = phase.image {
                        //Success Image
                        image.resizable()
                            .scaledToFit()
                            .frame(width:150, height: 150)
                        
                    } else if phase.error != nil {
                        //Error Image
                        Image(systemName: "ant.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width:150, height: 150)
                    } else {
                        //Default Image or Loading
                        //Image(systemName: "photo.circle.fill")
                        Text("Loading Image...")
                        ProgressView()
                            .scaleEffect(2.0)
                    }
                }
                
                //HEART
                Image(systemName: recipe.isFavorite ? "heart.fill" : "")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                    .offset(x:50, y:-50)
                
            }
            .padding(.horizontal)
            .padding(.top)
        
            //LABELS
            VStack(alignment:.center, spacing:5){
                
                Text(recipe.name)
                        .allowsTightening(true)
                        .frame(width: 150, alignment: .center)
                        .font(.title3).bold()
                        .foregroundStyle(Color.purple)
                
                    Text(recipe.cuisine)
                        .font(.subheadline).bold()
                        .foregroundStyle(Color.secondary)
                        .padding(.bottom,5)
            }
            
        }
        //.foregroundStyle(Color.blue.opacity(0.8))
        //.background(Color.red)
        .frame(width:180, height: 250)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay{
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.purple, lineWidth: 5)
        }
        
        
    }
}

#Preview {
    RecipeCardView(recipe: Response.completeSample[0])
}
