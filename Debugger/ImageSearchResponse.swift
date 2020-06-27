//
//  SearchResponse.swift
//  Debugger
//
//  Created by Gerry Low on 2020-06-26.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

struct ImageSearchResponse: Codable {
    let total: Int
    let totalHits: Int
    let hits: [ImageInfo]
}
