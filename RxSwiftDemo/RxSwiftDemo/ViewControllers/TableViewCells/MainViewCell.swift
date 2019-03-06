//
//  MainViewCell.swift
//  RxSwiftDemo
//
//  Created by QDSG on 2019/3/6.
//  Copyright © 2019 QDSG. All rights reserved.
//

import UIKit

class MainViewCell: UITableViewCell {
    
    static let reuseIdentifier = "MainViewCell"
    
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
