//
//  ProfileConfigurationCell.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/16.
//

import UIKit

class ProfileConfigurationCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellImageView.tintColor = .darkGray
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
