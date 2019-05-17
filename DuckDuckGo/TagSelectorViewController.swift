//
//  TagSelectorViewController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 17/05/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import UIKit

class TagSelectorViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self

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
        return 12
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tag", for: indexPath) as? TagCollectionViewCell else {
            fatalError("Unexpected cell")
        }

        switch indexPath.row {
        case 0: cell.name = "entertainment"
        case 1: cell.name = "technology"
        case 2: cell.name = "games"
        default: cell.name = "unknown"
        }

        return cell
    }

}

class TagCollectionViewCell: UICollectionViewCell {

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

}
