//
//  Users.swift
//  Instagram
//
//  Created by Karan Mehta on 28/08/22.
//

import Foundation

struct Users: Codable, Identifiable {
    var id = UUID()
    var contentURL: [String]!
    var profileImageName: String!
    var profileImageNameArray = ["Karan", "Tirth", "Pavan", "Groot", "Profile_One","Profile_Two"]
    var likedVideos = [String]()
    var likedImages = [String]()
}

struct Url: Codable {
    var users = [Users]()
    var urls = [
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
        "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
        "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
        "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerFun.jpg",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerMeltdowns.jpg",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/SubaruOutbackOnStreetAndDirt.jpg",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
    ]
    mutating func createUsers() -> [Users] {
        var indexForUser = 0
        while indexForUser < 6 {
            var user = Users()
            user.profileImageName = user.profileImageNameArray[indexForUser]
            users.append(user)
            indexForUser += 1
        }
        distributeURLRandomly()
        return users
    }
    mutating func distributeURLRandomly() {
        urls = urls.shuffled()
        let distributeSize = urls.count / 6
        let distributedURL = urls.chunked(into: distributeSize)
        var indexOfUser = 0
        while indexOfUser < distributedURL.count {
            if indexOfUser < users.count {
                users[indexOfUser].contentURL = distributedURL[indexOfUser]
            }
            else {
                let randomIndex = Int.random(in: 0...5)
                var indexOfURL = 0
                while indexOfURL < distributedURL[indexOfUser].count {
                    users[randomIndex].contentURL.append(distributedURL[indexOfUser][indexOfURL])
                    indexOfURL += 1
                }
            }
            
            indexOfUser += 1
        }
        indexOfUser = 0
        while indexOfUser < users.count {
            print(users[indexOfUser].contentURL ?? ["",""])
            indexOfUser += 1
        }
    }
}
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size,count)])
        }
    }
}
