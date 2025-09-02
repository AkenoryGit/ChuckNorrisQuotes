//
//  QuoteModel.swift
//  ChuckNorrisQuotes
//
//  Created by Дмитрий Дудник on 02.09.2025.
//

import Foundation
import RealmSwift

class Category: Object {
    @Persisted(primaryKey: true) var name: String
}

class Quote: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var text: String
    @Persisted var category: Category?
    @Persisted var createdAt: Date = Date()
}
