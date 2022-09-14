//
//  StoryCell.swift
//  Instagram
//
//  Created by Karan Mehta on 29/08/22.
//

import UIKit

class StoryCell: UICollectionViewCell {
    
    @IBOutlet weak var storyProgressView: UIProgressView!
    override func layoutSubviews() {
        super.layoutSubviews()
        storyProgressView.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height / 2)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        storyProgressView.setProgress(0.0, animated: true)
    }
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}
