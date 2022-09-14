//
//  StoryViewController.swift
//  Instagram
//
//  Created by Karan Mehta on 29/08/22.
//

import UIKit
import AVKit
class StoryViewController: UIViewController {
    var userIndex = 0
    var storyIndex = 0
    var users: [Users]!
    var images = [UIImage]()
    var timer: Timer!
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var videoPlayCount = 0
    var imageLoadCount = 0
    var imageIndex = 0
    var holdImage = false
    var holdVideo = false
    var isLikeVideoTapped = false
    var isLikeImageTapped = false
    var storyPressed = false
    var url = ""
    var swipeLeftImage = false
    var swipeRightImage = false
    var swipeLeftVideo = false
    var swipeRightVideo = false
    var userFavourites = [String]()
    var loadingDataProgressIndicator = UIActivityIndicatorView(style: .large)
    
    @IBOutlet weak var imageStory: UIImageView!
    @IBOutlet weak var imageLike: UIImageView!
    @IBOutlet weak var videoLike: UIImageView!
    @IBOutlet var storyImageView: UIView!
    @IBOutlet weak var storyVideoView: UIView!
    @IBOutlet weak var storyCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        storyCollectionView.dataSource = self
        storyCollectionView.delegate = self
        videoLike.tintColor = .init(white: 1.0, alpha: 0.5)
        avPlayer = AVPlayer(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4")!)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = storyVideoView.bounds
        storyVideoView.layer.addSublayer(avPlayerLayer)
        self.imageLike.isUserInteractionEnabled = true
        self.videoLike.isUserInteractionEnabled = true
        
        // Story Tap , Hold, Like Recognizers for both image and video
        let imagetapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapAction))
        let videotapRecognizer = UITapGestureRecognizer(target: self, action: #selector(videoTapAction))
        
        let imageLikeRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageLikeAction))
        let videoLikeRecognizer = UITapGestureRecognizer(target: self, action: #selector(videoLikeAction))
        
        let swipeImageLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftGesture))
        swipeImageLeftGesture.direction = .left
        let swipeImageRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightGesture))
        swipeImageRightGesture.direction = .right
        let swipeVideoLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftGesture))
        swipeVideoLeftGesture.direction = .left
        let swipeVideoRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightGesture))
        swipeVideoRightGesture.direction = .right
        
        let holdImageRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(holdImageAction))
        let holdVideoRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(holdVideoAction))
        
        checkNextMediaType()
        
        self.storyImageView.backgroundColor = .red
        self.storyImageView.addGestureRecognizer(imagetapRecognizer)
        self.storyVideoView.addGestureRecognizer(videotapRecognizer)
        
        self.imageLike.addGestureRecognizer(imageLikeRecognizer)
        self.videoLike.addGestureRecognizer(videoLikeRecognizer)
        
        self.storyImageView.addGestureRecognizer(swipeImageLeftGesture)
        self.storyImageView.addGestureRecognizer(swipeImageRightGesture)
        self.storyVideoView.addGestureRecognizer(swipeVideoLeftGesture)
        self.storyVideoView.addGestureRecognizer(swipeVideoRightGesture)
        
        self.storyImageView.addGestureRecognizer(holdImageRecognizer)
        self.storyVideoView.addGestureRecognizer(holdVideoRecognizer)
        
        // Loading indicator while data is being loaded from url
        loadingDataProgressIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(loadingDataProgressIndicator)
        loadingDataProgressIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loadingDataProgressIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        // setting like button size runtime
        //        videoLike.translatesAutoresizingMaskIntoConstraints = false
        //        videoLike.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.10).isActive = true
        //        videoLike.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.10).isActive = true
    }
    // storing user liked stories in default storage while they are exiting story view
    override func viewWillDisappear(_ animated: Bool) {
        if UserDefaults.standard.value(forKey: "myLikedStories") == nil {
            UserDefaults.standard.set(userFavourites, forKey: "myLikedStories")
        }
        else {
            var index = 0
            var tempArray = [String]()
            let likedStories = UserDefaults.standard.value(forKey: "myLikedStories") as! [String]
            while index < userFavourites.count {
                if !likedStories.contains(userFavourites[index]) {
                    tempArray.append(userFavourites[index])
                }
                index += 1
            }
            if tempArray.count > 0 {
                UserDefaults.standard.set(likedStories+tempArray, forKey: "myLikedStories")
            }
        }
    }
    
    @objc func holdImageAction(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            holdImage = false
        }
        else {
            holdImage = true
        }
    }
    
    @objc func holdVideoAction(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            avPlayer.play()
            self.timer.invalidate()
        }
        else {
            avPlayer.pause()
        }
    }
    
    @objc func swipeLeftGesture() {
        if userIndex < users.count - 1 {
            if users[userIndex].contentURL[storyIndex].suffix(3) != "mp4" {
                imageIndex += 1
            }
            userIndex += 1
            storyIndex = 0
            videoPlayCount = 0
            imageLoadCount = 0
            UIView.transition(with: storyVideoView, duration: 1, options: [.curveLinear,.transitionFlipFromRight], animations: nil, completion: nil)
            if users[userIndex].contentURL[storyIndex].suffix(3) == "mp4" {
                self.storyVideoView.isHidden = false
                self.storyImageView.isHidden = true
            }
            else {
                self.storyVideoView.isHidden = true
                self.storyImageView.isHidden = false
            }
            swipeLeftVideo = true
        }
        else {
            gotoProfileViewController()
        }
    }
    
    @objc func swipeRightGesture() {
        if userIndex - 1 >= 0 {
            if let cell = storyCollectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: IndexPath(index: storyIndex)) as? StoryCell {
                cell.storyProgressView.setProgress(0, animated: true)
            }
            if users[userIndex].contentURL[storyIndex].suffix(3) != "mp4" {
                imageIndex -= 1
            }
            storyIndex = 0
            videoPlayCount = 0
            imageLoadCount = 0
            userIndex -= 1
            
            UIView.transition(with: storyVideoView, duration: 1, options: [.curveLinear,.transitionFlipFromLeft], animations: nil, completion: nil)
            
            if users[userIndex].contentURL[storyIndex].suffix(3) == "mp4" {
                self.storyVideoView.isHidden = false
                self.storyImageView.isHidden = true
            }
            else {
                self.storyVideoView.isHidden = true
                self.storyImageView.isHidden = false
            }
            swipeRightVideo = true
        }
        else {
            self.gotoProfileViewController()
        }
    }
    
    @objc func imageLikeAction() {
        isLikeImageTapped.toggle()
        if !userFavourites.contains(users[userIndex].contentURL[storyIndex]) && isLikeImageTapped {
            imageLike.image = UIImage(systemName: "heart.fill")
            userFavourites.append(users[userIndex].contentURL[storyIndex])
        }
        else {
            imageLike.image = UIImage(systemName: "heart")
            userFavourites.remove(at: userFavourites.firstIndex(of: users[userIndex].contentURL[storyIndex])!)
        }
    }
    
    @objc func videoLikeAction() {
        if !userFavourites.contains(users[userIndex].contentURL[storyIndex])  {
            videoLike.image = UIImage(systemName: "heart.fill")
            userFavourites.append(users[userIndex].contentURL[storyIndex])
        }
        else {
            videoLike.image = UIImage(systemName: "heart")
            userFavourites.remove(at: users[userIndex].contentURL.firstIndex(of: users[userIndex].contentURL[storyIndex])!)
        }
    }
    
    @objc func imageTapAction() {
        if userIndex == users.count - 1  && storyIndex == users[userIndex].contentURL.count {
            gotoProfileViewController()
        }
        else {
            storyPressed = true
        }
    }
    
    @objc func videoTapAction() {
        avPlayer?.pause()
        avPlayer?.replaceCurrentItem(with: nil)
        if userIndex == users.count - 1  && storyIndex == users[userIndex].contentURL.count {
            gotoProfileViewController()
        }
        else {
            storyPressed = true
        }
    }
    // find duration of current video to be played
    func durationVideo(url: String) ->Double {
        let asset = AVAsset(url: URL(string: url)!)
        let duration = asset.duration
        return CMTimeGetSeconds(duration)
    }
    
    func playVideo(url: String) {
        storyImageView.frame = CGRect(x: self.view.frame.origin.x, y: self.storyCollectionView.frame.maxY + 10, width: self.view.frame.width, height: self.view.frame.height - 10)
        avPlayer = AVPlayer(url: URL(string: url)!)
        avPlayerLayer.player = avPlayer
        avPlayerLayer.frame = CGRect(x: self.storyVideoView.frame.origin.x, y: self.storyVideoView.frame.origin.y, width: self.storyVideoView.frame.width, height: self.storyVideoView.frame.height)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resize
        self.storyVideoView.bringSubviewToFront(self.videoLike)
        avPlayer.play()
        videoPlayCount += 1
    }
    
    func loadImage(url: String) {
        storyVideoView.isHidden = true
        imageLoadCount += 1
        storyImageView.frame = CGRect(x: self.view.frame.origin.x, y: self.storyCollectionView.frame.maxY + 10, width: self.view.frame.width, height: self.view.frame.height - 10)
        self.view.addSubview(storyImageView)
        storyImageView.backgroundColor = .blue
        imageStory.image = images[imageIndex]
        imageStory.frame = storyImageView.bounds
        storyImageView.addSubview(imageStory)
        storyImageView.bringSubviewToFront(imageLike)
        imageIndex += 1
        
    }
    
    func resetVariablesAndReloadCollectionView() {
        self.storyIndex = 0
        self.imageLoadCount = 0
        self.videoPlayCount = 0
        if userIndex < users.count - 1 {
            self.userIndex += 1
        }
        UIView.transition(with: storyVideoView, duration: 0.7, options: [.curveLinear, .transitionFlipFromRight],animations: nil, completion: nil)
        self.storyCollectionView.reloadData()
    }
    
    func incrementStoryIndexAndResetVariables() {
        if storyIndex < users[userIndex].contentURL.count - 1 {
            self.storyIndex += 1
            self.imageLoadCount = 0
            self.videoPlayCount = 0
        }
        else {
            if userIndex < users.count {
                resetVariablesAndReloadCollectionView()
            }
            else {
                gotoProfileViewController()
            }
        }
    }
    func checkNextMediaType() {
        if self.users[self.userIndex].self.contentURL[self.storyIndex].suffix(3) == "mp4" {
            self.storyImageView.isHidden = true
            self.storyVideoView.isHidden = false
        }
        else {
            self.storyImageView.isHidden = false
            self.storyVideoView.isHidden = true
        }
    }
    
    func gotoProfileViewController() {
        self.timer.invalidate()
        UIView.transition(with: storyVideoView, duration: 0.3, options: [.curveEaseOut, .transitionFlipFromTop], animations: nil, completion:  {_ in
            self.navigationController?.popViewController( animated: true)
        })
    }
}

extension UIImageView {
    func loadImageFromURL(url: String) async {
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            if let _ = response {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data!)
                }
            }
        }
        task.resume()
    }
}
extension StoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: indexPath) as? StoryCell {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
                if self.swipeLeftVideo || self.swipeRightVideo || self.swipeLeftImage || self.swipeRightImage {
                    self.swipeLeftImage = false
                    self.swipeRightImage = false
                    self.swipeLeftVideo = false
                    self.swipeRightVideo = false
                    timer.invalidate()
                    self.storyCollectionView.reloadData()
                }
                if indexPath.row == self.storyIndex {
                    self.url = self.users[self.userIndex].self.contentURL[self.storyIndex]
                    let typeOfMedia = self.users[self.userIndex].self.contentURL[self.storyIndex].suffix(3)
                    if typeOfMedia == "mp4" {
                        if UserDefaults.standard.value(forKey: "myLikedStories") == nil {
                            if self.userFavourites.contains(self.url) {
                                self.videoLike.image = UIImage(systemName: "heart.fill")
                            }
                            else {
                                self.videoLike.image = UIImage(systemName: "heart")
                            }
                        }
                        else {
                            let arrayOfLikedStories = UserDefaults.standard.value(forKey: "myLikedStories") as! [String]
                            if arrayOfLikedStories.contains(self.url) || self.userFavourites.contains(self.url){
                                self.videoLike.image = UIImage(systemName: "heart.fill")
                            }
                            else {
                                self.videoLike.image = UIImage(systemName: "heart")
                            }
                            
                        }
                        if self.videoPlayCount == 0 {
                            self.playVideo(url: self.url)
                        }
                        
                        let duration = self.durationVideo(url: self.url)
                        let currentItem = self.avPlayer.currentItem
                        let currentPlayingTime = currentItem?.currentTime()
                        
                        if self.storyPressed {
                            timer.invalidate()
                            
                            cell.storyProgressView.setProgress(1.0, animated: true)
                            self.storyPressed = false
                            self.incrementStoryIndexAndResetVariables()
                            self.checkNextMediaType()
                        }
                        else if CMTimeGetSeconds(currentPlayingTime ?? CMTime(value: 0, timescale: 1)) > 0 {
                            self.loadingDataProgressIndicator.stopAnimating()
                            self.storyCollectionView.isHidden = false
                            self.storyVideoView.isHidden = false
                            self.videoLike.isHidden = false
                            if Float64(CMTimeGetSeconds(self.avPlayer.currentTime())) / duration != 1.0  {
                                if CMTimeGetSeconds(currentPlayingTime ?? CMTime(seconds: 0, preferredTimescale: CMTimeScale())) > 0 {
                                    if !self.holdVideo {
                                        UIView.animate(withDuration: TimeInterval(duration)) {
                                            if !self.holdVideo {
                                                cell.storyProgressView.setProgress(1.0, animated: true)
                                            }
                                        }
                                    }
                                }
                            }
                            else if Float64(CMTimeGetSeconds(self.avPlayer.currentTime())) / duration == 1.0 || cell.storyProgressView.progress == 1.0 {
                                timer.invalidate()
                                self.videoPlayCount = 0
                                self.avPlayer.pause()
                                self.avPlayer.replaceCurrentItem(with: nil)
                                if self.storyIndex < self.users[self.userIndex].self.contentURL.count - 1 {
                                    self.incrementStoryIndexAndResetVariables()
                                    self.checkNextMediaType()
                                }
                                else {
                                    if self.userIndex < self.users.count  {
                                        self.resetVariablesAndReloadCollectionView()
                                        self.checkNextMediaType()
                                    }
                                    else {
                                        self.gotoProfileViewController()
                                    }
                                }
                            }
                            
                        }
                        else {
                            self.storyCollectionView.isHidden = true
                            self.storyVideoView.isHidden = true
                            self.videoLike.isHidden = true
                            self.loadingDataProgressIndicator.startAnimating()
                        }
                    }
                    else {
                        if self.imageLoadCount == 0 {
                            Task {
                                await self.loadImage(url: self.url)
                            }
                        }
                        if self.imageStory.image != nil {
                            UIView.animate(withDuration: 16.0) {
                                cell.storyProgressView.setProgress(1.0, animated: true)
                            }
                        }
                        if cell.storyProgressView.progress == 1.0 {
                            timer.invalidate()
                            if self.storyIndex < self.users[self.userIndex].self.contentURL.count - 1 {
                                self.incrementStoryIndexAndResetVariables()
                                self.checkNextMediaType()
                            }
                            else {
                                if self.userIndex < self.users.count  {
                                    self.resetVariablesAndReloadCollectionView()
                                    self.checkNextMediaType()
                                }
                                else {
                                    self.gotoProfileViewController()
                                }
                            }
                        }
                        
                        else {
                            self.storyImageView.isHidden = true
                            self.imageLike.isHidden = true
                            self.storyCollectionView.isHidden = true
                            self.loadingDataProgressIndicator.startAnimating()
                        }
                        
                        if self.storyPressed == true {
                            timer.invalidate()
                            UIView.animate(withDuration: 0.1) {
                                cell.storyProgressView.setProgress(1.0, animated: true)
                            }
                            self.storyPressed = false
                        }
                    }
                }
            })
            return cell
        }
        return UICollectionViewCell()
    }
}
extension StoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int(self.view.frame.width) / self.users[userIndex].contentURL.count - 10, height: 10)
    }
}


