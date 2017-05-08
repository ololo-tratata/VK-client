//
//  DialogTableViewCell.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/6/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//

import UIKit

public class DialogTableViewCell: UITableViewCell {

    @IBOutlet weak var dialogName: UILabel!
    @IBOutlet weak var message: UILabel!

    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
