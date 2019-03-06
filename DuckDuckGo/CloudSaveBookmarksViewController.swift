//
//  CloudSaveBookmarksViewController.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 06/03/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import UIKit
import Alamofire
import Core

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

    var bookmarks: [CloudSaveBookmark] {
        return []
    }

    var bookmarksCode: String?
    var busy = false

    override func viewDidLoad() {
        super.viewDidLoad()

        print("***", "test".data(using: .utf8)?.sha512)

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

        let code = UUID().uuidString
        guard let key = code.data(using: .utf8)?.sha512 else {
            fatalError("Unable to create key for \(code)")
        }

        let url = URL(string: "https://brindy.duckduckgo.com/bookmarks.js")!

        let parameters: [String: Any] = [
            "command": "write",
            "objectKey": key,
            "obj": bookmarks
        ]

        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .responseData(queue: DispatchQueue.main) { [weak self] response in

                if response.error != nil {
                    print("***", response.error)
                    self?.view.makeToast("Failed to save bookmarks, try again later.")
                    return
                }

                if response.data != nil {
                    self?.bookmarksCode = key
                }

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

struct CloudSaveBookmark: Codable {

    let title: String
    let url: String

}

struct CloudSaveBookmarksObject: Codable {

    let bookmark: [CloudSaveBookmark]

}

struct CloudSave: Codable {

    let command: String
    let objectKey: String
    let obj: CloudSaveBookmarksObject

}

