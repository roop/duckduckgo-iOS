//
//  CloudSaveBookmarksViewController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 06/03/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import UIKit

class CloudSaveBookmarksViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var uploadImage: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var qrcodeImage: UIImageView!

    @IBAction func close() {
        dismiss(animated: true)
    }

    @IBAction func handleButtonTap() {

        if bookmarksCode != nil {

            // prompt to confirm

        } else {
            saveToCloud()
        }

    }

    var bookmarksCode: String?
    var busy = false

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshUI()
    }

    func refreshUI() {
        updateQRCode()
        updateInfo()
        updateButton()
        updateActivity()
    }

    func updateActivity() {
        if busy {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    func saveToCloud() {
        busy = true
        refreshUI()

        

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.bookmarksCode = "test"
            self?.busy = false
            self?.refreshUI()
        }
    }

    func updateQRCode() {
         // show it if we have one
    }

    func updateInfo() {
        infoLabel.isHidden = busy || bookmarksCode != nil
        uploadImage.isHidden = busy || bookmarksCode != nil
    }

    func updateButton() {

        button.isHidden = busy

        if bookmarksCode != nil {
            button.backgroundColor = UIColor.red
            button.setTitle("Delete from Cloud", for: .normal)
        } else {
            button.backgroundColor = UIColor.cornflowerBlue
            button.setTitle("Save to Cloud", for: .normal)
        }

    }

}
