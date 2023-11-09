//
//  CacheEntry.swift
//  ForecastFavorApp_iOS
//
//  Created by Daphne Rivera on 2023-11-08.
//

import Foundation

final class CacheEntryObject {
    let entry: CacheEntry
    init(entry: CacheEntry) {
        self.entry = entry
    }
}

enum CacheEntry {
    case inProgress(Task<Data, Error>)
    case ready(Data)
}
