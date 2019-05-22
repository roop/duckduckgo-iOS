//
//  BookmarksManager.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Core

class BookmarksManager {

    private var dataStore: BookmarkStore

    init(dataStore: BookmarkStore = BookmarkUserDefaults()) {
        self.dataStore = dataStore
    }

    var bookmarksCount: Int {
        return bookmarks().count
    }
    
    var favoritesCount: Int {
        return favorites().count
    }

    var tags: [String] {
        return [String](Set<String>((dataStore.bookmarks + dataStore.favorites).compactMap { $0.tags }.flatMap { $0 })).sorted()
    }

    var tagFilter: String?

    func filter(_ tag: String?) {
        tagFilter = tag
    }

    private func bookmarks() -> [Link] {
        return dataStore.bookmarks.filter(includeLink)
    }

    private func favorites() -> [Link] {
        return dataStore.favorites.filter(includeLink)
    }

    private func includeLink(link: Link) -> Bool {
        return tagFilter == nil || link.tags?.contains(tagFilter!) ?? true
    }

    func bookmark(atIndex index: Int) -> Link? {
        let links = bookmarks()
        return links.count > index ? links[index] : nil
    }

    func favorite(atIndex index: Int) -> Link? {
        let links = favorites()
        return links.count > index ? links[index] : nil
    }

    func save(bookmark: Link) {
        dataStore.addBookmark(bookmark)
    }

    func save(favorite: Link) {
        dataStore.addFavorite(favorite)
    }

    func moveFavorite(at favoriteIndex: Int, toBookmark bookmarkIndex: Int) {
        let link = dataStore.favorites[favoriteIndex]
        var favorites = dataStore.favorites
        var bookmarks = dataStore.bookmarks

        if bookmarks.count < bookmarkIndex {
            bookmarks.append(link)
        } else {
            bookmarks.insert(link, at: bookmarkIndex)
        }
        favorites.remove(at: favoriteIndex)
        
        dataStore.bookmarks = bookmarks
        dataStore.favorites = favorites
    }

    func moveFavorite(at fromIndex: Int, to toIndex: Int) {
        var favorites = dataStore.favorites
        let link = favorites.remove(at: fromIndex)
        favorites.insert(link, at: toIndex)
        dataStore.favorites = favorites
    }
    
    func moveBookmark(at bookmarkIndex: Int, toFavorite favoriteIndex: Int) {
        let link = dataStore.bookmarks[bookmarkIndex]
        var bookmarks = dataStore.bookmarks
        var favorites = dataStore.favorites

        if favorites.count < favoriteIndex {
            favorites.append(link)
        } else {
            favorites.insert(link, at: favoriteIndex)
        }
        bookmarks.remove(at: bookmarkIndex)
        
        dataStore.bookmarks = bookmarks
        dataStore.favorites = favorites
    }
    
    func moveBookmark(at fromIndex: Int, to toIndex: Int) {
        var bookmarks = dataStore.bookmarks
        let link = bookmarks.remove(at: fromIndex)
        bookmarks.insert(link, at: toIndex)
        dataStore.bookmarks = bookmarks
    }

    func deleteBookmark(at index: Int) {
        var bookmarks = dataStore.bookmarks
        bookmarks.remove(at: index)
        dataStore.bookmarks = bookmarks
    }

    func deleteFavorite(at index: Int) {
        var favorites = dataStore.favorites
        favorites.remove(at: index)
        dataStore.favorites = favorites
    }

    func updateFavorite(at index: Int, with link: Link) {
        var favorites = dataStore.favorites
        _ = favorites.remove(at: index)
        favorites.insert(link, at: index)
        dataStore.favorites = favorites
    }

    func updateBookmark(at index: Int, with link: Link) {
        var bookmarks = dataStore.bookmarks
        _ = bookmarks.remove(at: index)
        bookmarks.insert(link, at: index)
        dataStore.bookmarks = bookmarks
    }

    func contains(url: URL) -> Bool {
        return nil != indexOfFavorite(url: url) || nil != indexOfBookmark(url: url)
    }

    private func indexOfBookmark(url: URL) -> Int? {
        return indexOf(url, in: bookmarks())
    }

    private func indexOfFavorite(url: URL) -> Int? {
        return indexOf(url, in: favorites())
    }
    
    private func indexOf(_ url: URL, in links: [Link]) -> Int? {
        var index = 0
        for link in links {
            if link.url == url {
                return index
            }
            index += 1
        }
        return nil
    }
    
    func migrateFavoritesToBookmarks() {
        while favoritesCount > 0 {
            moveFavorite(at: 0, toBookmark: 0)
        }
    }
    
}
