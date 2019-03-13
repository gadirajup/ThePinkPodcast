//
//  APIService.swift
//  ThePinkPodcast
//
//  Created by Prudhvi Gadiraju on 3/8/19.
//  Copyright © 2019 Prudhvi Gadiraju. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

class APIService {
    // Singleton
    static let shared = APIService()
    
    func fetchEpisodes(feedUrl: String, completion: @escaping ([Episode]) -> ()) {
        let secureFeedUrl = feedUrl.toSecureHTTPS()
        guard let url = URL(string: secureFeedUrl) else {return}
        
        DispatchQueue.global(qos: .background).async {
            let parser = FeedParser(URL: url)
            parser?.parseAsync(result: { (result) in
                
                if let err = result.error {
                    print("Failed to parse XML Feed: ",err)
                    return
                }
                
                guard let feed = result.rssFeed else {return}
                let episodes = feed.toEpisodes()
                completion(episodes)
            })
        }
    }
    
    func fetchPodcasts(searchText: String, completion: @escaping ([Podcast]) -> (Void)) {
        let url = "https://itunes.apple.com/search"
        let parameters = ["term": searchText, "media": "podcast"]
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).response { (dataResponse) in
            if let error = dataResponse.error {
                print("Failed to contact iTunes", error)
                return
            }
            guard let data = dataResponse.data else {return}
            do {
                let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                completion(searchResult.results)
            } catch {
                print("Failed to Decode ", error.localizedDescription)
            }
        }
    }
    
    func downloadEpisode(episode: Episode) {
        
        let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        
        Alamofire.download(episode.streamUrl, to: downloadRequest).downloadProgress { (progress) in
            print(progress.fractionCompleted)
            
            NotificationCenter.default.post(name: NotificationCenter.name, object: nil, userInfo: ["title":episode.title, "progress": progress.fractionCompleted])
            
            }.response { (resp) in
                print(resp.destinationURL?.absoluteString ?? "")
                
                var downloadedEpisodes = UserDefaults.standard.fetchDownloadedEpisodes()
                guard let index = downloadedEpisodes.firstIndex(where: { (e) -> Bool in
                    e.title == episode.title
                }) else {return}
                downloadedEpisodes[index].fileUrl = resp.destinationURL?.absoluteString ?? ""
                
                UserDefaults.standard.updateDownloadedEpisodes(withEpisodes: downloadedEpisodes)
        }
    }
    
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
}
