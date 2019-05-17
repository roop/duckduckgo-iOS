//
//  TagSelectorViewController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 17/05/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import UIKit

protocol TagSelectorDelegate: NSObjectProtocol {

    func tagSelected(name: String)

    func clearTagSelection()

}

class TagSelectorViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    weak var delegate: TagSelectorDelegate?

    var selectedTag: String?

    var tags: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self

        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("Wrong layout type")
        }

        flowLayout.estimatedItemSize = CGSize(width: 100, height: 42)
        flowLayout.scrollDirection = .horizontal
    }

}

extension TagSelectorViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = tags?.count else {
            return 0
        }

        if selectedTag != nil {
            return 2
        }

        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if selectedTag != nil && indexPath.row == 1 {
            return dismissCell(for: indexPath)
        } else if let name = selectedTag {
            return tagCell(withName: name, for: indexPath)
        } else if let name = tags?[indexPath.row] {
            return tagCell(withName: name, for: indexPath)
        }

        fatalError("Couldn't determine which cell to return")
    }

    private func dismissCell(for indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Dismiss", for: indexPath) as? DismissSelectedTagCell else {
            fatalError("Unexpected cell")
        }
        return cell
    }

    private func tagCell(withName name: String, for indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tag", for: indexPath) as? TagCollectionViewCell else {
            fatalError("Unexpected cell")
        }
        cell.name = name
        return cell
    }

}

extension TagSelectorViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectable = collectionView.cellForItem(at: indexPath) as? SelectableTagCell else {
           return
        }
        selectable.selected(controller: self, atIndexPath: indexPath)
    }

}

protocol SelectableTagCell {

    func selected(controller: TagSelectorViewController, atIndexPath indexPath: IndexPath)

}

class DismissSelectedTagCell: UICollectionViewCell, SelectableTagCell {

    @IBOutlet weak var clearImage: UIImageView!

    func selected(controller: TagSelectorViewController, atIndexPath indexPath: IndexPath) {
        controller.selectedTag = nil
        controller.delegate?.clearTagSelection()
        controller.collectionView.reloadData()
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        layoutAttributes.size = CGSize(width: 20, height: 42)
        clearImage.tintColor = ThemeManager.shared.currentTheme.buttonTintColor
        return layoutAttributes
    }

}

class TagCollectionViewCell: UICollectionViewCell, SelectableTagCell {

    @IBOutlet weak var label: UILabel!

    var name: String? {
        get {
            return label.text
        }

        set {
            label.text = newValue
        }
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {

        let width = ((name?.count ?? 2) * 6) + 14

        layoutAttributes.size = CGSize(width: width, height: 42)
        return layoutAttributes
    }

    func selected(controller: TagSelectorViewController, atIndexPath indexPath: IndexPath) {
        guard controller.selectedTag == nil else { return }
        guard let name = name else { return }
        guard let tags = controller.tags else { return }

        var deletedItems = [IndexPath]()

        for index in 2 ..< tags.count {
            deletedItems.append(IndexPath(row: index, section: 0))
        }

        controller.selectedTag = name
        controller.delegate?.tagSelected(name: name)
        controller.collectionView.deleteItems(at: deletedItems)
        controller.collectionView.reloadItems(at: [
            IndexPath(row: 0, section: 0),
            IndexPath(row: 1, section: 0)])
    }
}
