//
//  OCVSlideshow.swift
//  OCVSwift
//
//  Created by Eddie Seay on 2/23/16.
//  Copyright © 2016 OCV,LLC. All rights reserved.
//

import UIKit
import AlamofireImage
import SnapKit

class OCVSlideshow: UIView {

    let url: String!
    let shuffle: Bool

    let imageDownloader = ImageDownloader()
    var imageArray = [UIImage]()

    let primaryImage: UIImageView = {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        return $0
    }(UIImageView())

    let secondaryImage: UIImageView = {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        return $0
    }(UIImageView())

    var activityIndicator: UIActivityIndicatorView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alpha = 1.0
        return $0
    }(UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge))

    var currentIndex = 0
    var nextIndex = 0

    init(url: String, shuffle: Bool) {
        self.url = url
        self.shuffle = shuffle
        super.init(frame: CGRect.zero)
        setupSlideShow()

        if AppColors.oppositeOfPrimary.color == UIColor.white {
            activityIndicator.activityIndicatorViewStyle = .gray
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupSlideShow() {
        backgroundColor = AppColors.primary.color
        clipsToBounds = true
        contentMode = .scaleAspectFit
        configureImageViews()

        OCVNetworkClient().downloadFrom(url: url, showProgress: false) { resultData, _ in
            if resultData == nil { self.configureNoInternet()
            } else { self.downloadImagesFromArray(OCVFeedParser().parseImageLinks(resultData)) }
        }
    }

    func beginSlideShow() {
        activityIndicator.removeFromSuperview()
        if shuffle { imageArray = imageArray.shuffle() }
        goToNext()
    }

    func goToNext() {
        nextIndex = (currentIndex + 1) % (imageArray.count)
        secondaryImage.image = imageArray[nextIndex]
        currentIndex = nextIndex
        swapSlides()
    }

    func swapSlides() {
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.primaryImage.alpha = 0
        }, completion: { (finished) -> Void in
            self.primaryImage.image = self.secondaryImage.image
            self.primaryImage.alpha = 1

            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(OCVSlideshow.goToNext), object: nil)
            self.perform(#selector(OCVSlideshow.goToNext), with: nil, afterDelay: 4.0)
        }) 
    }

    func downloadImagesFromArray(_ urlArray: [URL]) {
        var downloadedImages = 0
        let totalImages = urlArray.count

        for imageURL in urlArray {
            let urlRequest = URLRequest(url: imageURL)
            imageDownloader.download(urlRequest) { response in
                if let image = response.result.value {
                    downloadedImages += 1
                    self.imageArray.append(image)
                    if downloadedImages == totalImages {
                        self.beginSlideShow()
                    }
                }
            }
        }
    }

    func configureImageViews() {

        addSubview(secondaryImage)
        addSubview(primaryImage)
        addSubview(activityIndicator)

        primaryImage.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }
        secondaryImage.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }
        activityIndicator.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(self)
        }

        activityIndicator.startAnimating()
    }

    func configureNoInternet() {
        activityIndicator.removeFromSuperview()
        secondaryImage.removeFromSuperview()

        if let staticImage = UIImage(named: "slider") {
            primaryImage.image = staticImage
        }
    }
}
