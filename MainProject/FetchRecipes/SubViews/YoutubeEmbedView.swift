//
//  YoutubeEmbedView.swift
//  FetchRecipes
//
//  Created by RMT on 5/12/25.
//
import SwiftUI
import WebKit

// A SwiftUI wrapper for WKWebView to embed YouTube videos
struct YoutubeEmbedView: UIViewRepresentable {
    let videoTitle: String
    let videoID: String // YouTube video ID

    // Creates the WKWebView instance Embeded "Web View"
    func makeUIView(context: Context) -> WKWebView {
        ///Configuration  to address those WebKit/WebPrivacy logs.
        ///logs may not be actual issues, setting things explicitly can sometimes suppress internal requests or make behavior more predictable.
            let config = WKWebViewConfiguration()
                /// Use a non-persistent data store (no cookies, caches, etc)
                /// Might reduce WebPrivacy-related logs
                config.websiteDataStore = .nonPersistent()  ///Avoids cookie/storage quirks that might be logged in WebPrivacy

                // Optional: disable JavaScript if not needed
                let pagePrefs = WKWebpagePreferences()
                pagePrefs.allowsContentJavaScript = true
                config.defaultWebpagePreferences = pagePrefs///Control if JavaScript should run — more secure with it off

                // Optional: tweak content security settings
                config.preferences.javaScriptCanOpenWindowsAutomatically = false ///Prevents popups

                // Optional: media playback settings
                config.allowsInlineMediaPlayback = true ///Allows videos to play without full screen
                config.mediaTypesRequiringUserActionForPlayback = [] ///Allows autoplay of video/audio
        //End Config
        
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    // Loads the YouTube video in Embeded "Web View" if Possible
    func updateUIView(_ webView: WKWebView, context: Context) {
        let embedHTML: String
        print("VIDEO ID In YoutubeEmbedView: \(String(describing: videoID))")
        
        //WITH ALERT
       
            //If VideoID Missing show Alert (Go to Browser)
            if videoID == "Missing Video ID"  {
                //UIKit Alert (B/c inside UIViewRepresentable SwiftUI<->UIKIt)
                DispatchQueue.main.async {
                    if let topViewController = UIApplication.topViewController() {
                        //Alert View
                        let alert = UIAlertController(
                            title: "Missing Video",
                            message: "The video could not be found. Would You like to search for it in YouTube?.",
                            preferredStyle: .alert
                        )
                        //OK
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                            openYouTubeAppForQuery(for:videoTitle)
                        })
                        //Cancel
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                            if let topViewController = UIApplication.topViewController() {
                                if let nav = topViewController.navigationController {
                                    nav.popViewController(animated: true)
                                } else {
                                    topViewController.dismiss(animated: true)
                                }
                            }
                        }))
                        
                        topViewController.present(alert, animated: true)
                    }
                }
                
                // If HTML Missing Video URL
                embedHTML = HTMLHelper.missingVideo
                
            } else {
                //Embed and Show Normal Youtube Video
                embedHTML = """
                    <html>
                    <body style="margin: 0; padding: 0;">
                    <iframe width="100%" height="100%"
                    src="https://www.youtube.com/embed/\(videoID)?playsinline=1"
                    frameborder="0" allowfullscreen></iframe>
                    </body>
                    </html>
                    """
            }
        
        
        webView.loadHTMLString(embedHTML, baseURL: nil) // Load the HTML string into the web view
    }
    
    //Function to Open a Search Queary in Youtube or Safari (Fall back for when Youtube URL is Missing)
    private func openYouTubeAppForQuery(for title:String = "Ice Cream Cake") {
        let searchQuery = title.replacingOccurrences(of: " ", with: "+")
        //Open in Youtube App
        let url = URL(string: "https://www.youtube.com/results?search_query=\(searchQuery)")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            //Open in Safari
            UIApplication.shared.open(URL(string: "https://www.youtube.com/results?search_query=\(searchQuery)")!)
        }
    }
    
    //CLEAN UP
    //*This is a *UIViewRepresentable-method called *automatically by SwiftUI when the view is removed from the hierarchy (e.g., when the view disappears or is deallocated).
    static func dismantleUIView(_ uiView: WKWebView, coordinator: ()) {
        // Stop video playback
        uiView.evaluateJavaScript("document.querySelector('video').pause();", completionHandler: nil)
        uiView.evaluateJavaScript("document.querySelector('video').currentTime = 0;", completionHandler: nil)
        // Clear cache
        URLCache.shared.removeAllCachedResponses()
        // Remove JavaScript handlers
        uiView.configuration.userContentController.removeAllUserScripts()
    }
        
}

//Helper to get the top-most view controller b/c we're working with UIViewPreresetable in our "YoutubeEmbedView"
//Only used Once at "YoutubeEmbedView"
extension UIApplication {
    static func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

struct HTMLHelper {
    static let missingVideo = """
    <html>
      <head>
        <style>
          html, body {
            margin: 0;
            padding: 0;
            height: 100%;
            width: 100%;
          }

          body {
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 24px;
            text-align: center;
          }
        </style>
      </head>
      <body>
        <p>Missing video URL</p>
      </body>
    </html>
    """
    
}
