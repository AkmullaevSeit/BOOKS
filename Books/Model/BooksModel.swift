//
//  BooksModel.swift
//  Books
//
//  Created by 1 on 15.11.2021.
//

import Foundation

struct BooksModel: Decodable {
    let context: String
    let id: String
    let type: String
    var hydraMember: [HydraMember]

    enum CodingKeys: String, CodingKey {
        case hydraMember = "hydra:member"
        case context = "@context"
        case id = "@id"
        case type = "@type"
    }
}

struct HydraMember: Decodable {
    let isbn: String
    let title: String
    let description: String
    let author: String

}

