//
//  RGFeedTableViewCell.swift
//  RGRedditClient
//
//  Created by Jose Humberto Partida Garduno on 11/30/18.
//  Copyright © 2018 Jose Humberto Partida Garduno. All rights reserved.
//

import UIKit

protocol RGFeedCellAction: class {
    func saveImageInAlbum(imageURLStr: String)
}

class RGFeedTableViewCell: UITableViewCell {
    static let thumbnailPlaceHolder = UIImage(named: "ImagePlaceHolder")
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var comments: UILabel!
    @IBOutlet weak var thumbnail: UIButton!
    var imageFromThumbnail: String?
    weak var feedCellAction: RGFeedCellAction?
    
    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(thumbnailTap(_:)))
        tap.numberOfTapsRequired = 1
        return tap
    }()
    
    fileprivate lazy var longPress: UILongPressGestureRecognizer = {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(savePhoto(_:)))
        longPress.minimumPressDuration = 1.5
        return longPress
    }()
    
    
    
    override func awakeFromNib() {
        commonInit()
    }
    
    private func commonInit() {
        title.text = ""
        author.text = ""
        time.text = ""
        comments.text = ""
        thumbnail.isHidden = true
        thumbnail.layer.cornerRadius = 1.5
        thumbnail.clipsToBounds = true
    }
    
    override func prepareForReuse() {
       resetCell()
    }
    
    func configure(with feed:RGFeed) {
        title.text = feed.title
        author.text = feed.author_fullname
        configureTime(for: feed)
        configureComments(from: feed)
        configureThumbnail(from: feed)
        imageFromThumbnail = feed.url
    }
    
    @objc fileprivate func savePhoto(_ sender: Any) {
        guard let feedAction = feedCellAction, let imageStr = imageFromThumbnail else {
            return
        }
        guard longPress.state == .began else {
            return
        }
        feedAction.saveImageInAlbum(imageURLStr: imageStr)
    }
    
    @objc fileprivate func thumbnailTap(_ sender: Any) {
        guard let imageFromThumbnail = imageFromThumbnail, let url = URL(string: imageFromThumbnail) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    fileprivate func resetCell() {
        title.text = ""
        author.text = ""
        time.text = ""
        comments.text = ""
        thumbnail.setImage(RGFeedTableViewCell.thumbnailPlaceHolder, for: .normal)
        thumbnail.setImage(RGFeedTableViewCell.thumbnailPlaceHolder, for: .selected)
    }
    
    fileprivate func configureTime(for feed: RGFeed) {
        guard let timeUTC = feed.created_utc, let timeDifference = getTimeStr(from: timeUTC) else {
            return
        }
        time.text = timeDifference
    }
    
    fileprivate func configureComments(from feed: RGFeed) {
        guard let numberOfComments = feed.num_comments, numberOfComments > 0 else {
            return
        }
        comments.text = comments(fromNumber: numberOfComments)
    }
    
    fileprivate func configureThumbnail(from feed: RGFeed) {
        thumbnail.isHidden = true
        guard let thumbnailString = feed.thumbnail, thumbnailString.hasPrefix("http://") || thumbnailString.hasPrefix("https://") else {
            thumbnail.isHidden = true
            return
        }
        if let imageFromCache = RGImageDownloader.imageCache.object(forKey: thumbnailString as AnyObject) as? UIImage {
            thumbnail.setImage(imageFromCache, for: .normal)
            thumbnail.setImage(imageFromCache, for: .selected)
            thumbnail.isHidden = false
            return
        }
        RGImageDownloader.downloadImage(from: thumbnailString, success: { [weak self] (image) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.thumbnail.isHidden = false
            strongSelf.thumbnail.setImage(image, for: .normal)
            strongSelf.thumbnail.setImage(image, for: .selected)
            strongSelf.thumbnail.addGestureRecognizer(strongSelf.tapGesture)
            strongSelf.thumbnail.addGestureRecognizer(strongSelf.longPress)
            strongSelf.thumbnail.setNeedsDisplay()
        }, fail: { (error) in
            
        })
    }
    
    fileprivate func getTimeStr(from interval: TimeInterval) -> String? {
        let now = Date()
        let postDate = Date(timeIntervalSince1970: interval)
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        guard let differenceHourAgo = calendar.dateComponents([.hour], from: now, to: postDate).hour else {
            return nil
        }
        
        return "\(abs(differenceHourAgo)) hours ago"
    }
    
    fileprivate func comments(fromNumber number: Int) -> String? {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        guard let numberFormatted = formatter.string(from: NSNumber(value: number)) else {
            return nil
        }
        return "\(numberFormatted) comments"
    }
}
