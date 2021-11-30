//
//  TableViewCell.swift
//  Test
//
//  Created by 近藤大伍 on 2021/11/04.
//

import UIKit

class DetailCell: UITableViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = 30
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
