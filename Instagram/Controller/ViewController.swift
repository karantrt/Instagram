//
//  ViewController.swift
//  Instagram
//
//  Created by Karan Mehta on 28/08/22.
//

import UIKit

class ViewController: UIViewController {
    var users: [Users]!
    var selectedUserIndex = 0
    var images = [UIImage]()
    var singleImage = UIImage()
    var index = 0
    @IBOutlet weak var userCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        userCollectionView.delegate = self
        userCollectionView.dataSource = self
        var urlUser = Url()
        users = urlUser.createUsers()
        while index < urlUser.urls.count {
            if urlUser.urls[index].suffix(3) != "mp4" {
                downloadImage(from: URL(string: urlUser.urls[index])!)
            }
            index += 1
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                self!.singleImage = UIImage(data: data)!
                self?.images.append(self!.singleImage)
            }
        }
    }
}
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "StoryViewController") as? StoryViewController  else {
            return
        }
        nextViewController.userIndex = indexPath.row
        nextViewController.users = users
        nextViewController.images = images
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath) as? ProfileCell {
            cell.configureImage(with: users[indexPath.row].profileImageName)
            return cell
        }
        return UICollectionViewCell()
    }
}
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
}












//extension UIImage {
//    public static func loadFrom(url: URL, completion: @escaping (_ image: UIImage?) -> ()) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            if let data = try? Data(contentsOf: url) {
//                DispatchQueue.main.async {
//                    completion(UIImage(data: data))
//                }
//            }
//            else {
//                DispatchQueue.main.async {
//                    completion(nil)
//                }
//            }
//        }
//}
