//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by CS193p Instructor on 4/27/20.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI

class EmojiArtDocument: ObservableObject
{
    @Published var selected: Set<EmojiArt.Emoji> = []
    static let palette: String = "⭐️⛈🍎🌏🥨⚾️"
    
    // @Published // workaround for property observer problem with property wrappers
    private var emojiArt: EmojiArt {
        willSet {
            objectWillChange.send()
        }
        didSet {
            UserDefaults.standard.set(emojiArt.json, forKey: EmojiArtDocument.untitled)
        }
    }
    
    private static let untitled = "EmojiArtDocument.Untitled"
    
    init() {
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtDocument.untitled)) ?? EmojiArt()
        fetchBackgroundImageData()
    }
        
    @Published private(set) var backgroundImage: UIImage?
    
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    
    // MARK: - Intent(s)
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func moveSelectedEmojis(by offset: CGSize) {
        for emoji in selected {
            moveEmoji(emoji, by: offset)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }

    func setBackgroundURL(_ url: URL?) {
        emojiArt.backgroundURL = url?.imageURL
        fetchBackgroundImageData()
    }
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        if url == self.emojiArt.backgroundURL {
                            self.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
    
    func toggleEmojiSelection(_ emoji: EmojiArt.Emoji) {
        print("\(#function), line: \(#line) Selected emojis: \(selected)")
        if selected.contains(matching: emoji) {
            selected.remove(at: selected.firstIndex(matching: emoji)!)
        } else {
            selected.insert(emoji)
        }
        print("\(#function), line: \(#line) Selected emojis: \(selected)")
    }
    
    func isEmojiSelected(_ emoji: EmojiArt.Emoji) -> Bool {
        return selected.contains(matching: emoji)
    }
    
    func noEmojisSelected() -> Bool {
        return selected.isEmpty
    }
    
    func deleteSelectedEmojis() {
        for emoji in selected {
            selected.remove(at: selected.firstIndex(matching: emoji)!)
            if let index = emojiArt.emojis.firstIndex(matching: emoji) {
                emojiArt.emojis.remove(at: index)
            }
        }
    }

    func deSelectAllEmojis() {
        selected.removeAll()
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}
