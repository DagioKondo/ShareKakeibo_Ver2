//
//  CollectionViewCell.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/21.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = 35
        // Initialization code
    }

}
