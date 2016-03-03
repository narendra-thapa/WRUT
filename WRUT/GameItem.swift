//
//  GameItem.swift
//  WRUT
//
//  Created by Narendra Thapa on 2016-03-02.
//  Copyright © 2016 Narendra Thapa. All rights reserved.
//

import UIKit

class GameItem {
    
    let image: UIImage?
    let owner: String?
    
    init(image: UIImage?, owner: String?)
    {
        self.image = image
        self.owner = owner
    }
}
