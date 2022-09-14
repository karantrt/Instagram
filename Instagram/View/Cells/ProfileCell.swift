//
//  ProfileCell.swift
//  Instagram
//
//  Created by Karan Mehta on 28/08/22.
//

import UIKit

class ProfileCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    func configureImage(with image: String) {
        profileImage.image = UIImage(named: image)
        profileImage.clipsToBounds = true
        profileImage.layer.masksToBounds = true
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = 150.0/2.0
        profileImage.backgroundColor = .black
        profileImage.layer.borderColor = UIColor.link.cgColor
    }
}
