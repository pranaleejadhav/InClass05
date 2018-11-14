//
//  Notebook.swift
//  InClass05
//
//  Created by Pranalee Jadhav on 11/14/18.
//  Copyright © 2018 Pranalee Jadhav. All rights reserved.
//

import Foundation

class Notebook {
    
    var id: String?
    var name: String?
    var created_date: String?
    
    
    init(id: String?, name: String?, created_date: String?){
        self.id = id
        self.name = name
        self.created_date = created_date
    }
}
