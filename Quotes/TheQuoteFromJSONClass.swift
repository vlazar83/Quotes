//
//  TheQuoteFromJSONClass.swift
//  Quotes
//
//  Created by Lazar, Viktor on 2019. 01. 18..
//  Copyright © 2019. Lazar, Viktor. All rights reserved.
//

import UIKit

class TheQuoteFromJSONClass: NSObject, Decodable {

    let success: Success
    let contents: Contents
    
    struct Quote: Decodable {
        let quote: String?
        let author: String?
        let tags: [String]?
        let category: String?
        let title: String?
        let date: String?
        let id: String?
        
        init() {
            quote = ""
            author = ""
            tags = [""]
            category = ""
            title = ""
            date = ""
            id = ""
        }
        
    }
    
    struct Contents: Decodable {
        let quotes: [Quote]
        let copyright: String
        
        init() {
            copyright = ""
            quotes = [Quote]()
        }
        
    }
    
    struct Success: Decodable {
        let total: Int
        init() {
            total = 1
        }
    }

}
