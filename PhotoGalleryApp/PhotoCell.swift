//
// Created by Hope on 2021/12/14.
//

import UIKit
import PhotosUI

let scale = UIScreen.main.scale

class PhotoCell: UICollectionViewCell {

    @IBOutlet
    var photoImageView: UIImageView! {
        didSet {
            photoImageView.contentMode = .scaleAspectFill
        }
    }

    var imageManager: PHImageManager = PHImageManager()

    var imageSize: CGSize = CGSize(width: 150 * scale, height: 150 * scale)

    func loadImage(phAsset: PHAsset) {
        imageManager.requestImage(for: phAsset, targetSize: imageSize, contentMode: .aspectFit, options: nil) { image, info in
            self.photoImageView.image = image
        }
    }
}
