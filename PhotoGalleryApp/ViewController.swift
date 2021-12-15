//
//  ViewController.swift
//  PhotoGalleryApp
//
//  Created by Hope on 2021/12/14.
//
//

import UIKit
import PhotosUI

class ViewController: UIViewController {


    var fetchAssets: PHFetchResult<PHAsset>?


    @IBOutlet
    var photoCollectionView: UICollectionView!

    override
    func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo Gallery App"
        makeNavigationItem()

        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 2 - 0.5, height: 200)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        photoCollectionView.collectionViewLayout = layout

        photoCollectionView.dataSource = self
    }

    /**
     초반에 네비게이션 쪽 아이템 만드는 로직
     */
    private func makeNavigationItem() {
        let photoItem = UIBarButtonItem(image: UIImage(systemName: "photo.on.rectangle.angled"), style: .plain, target: self, action: #selector(checkPermission))
        photoItem.tintColor = .black.withAlphaComponent(0.7)
        navigationItem.rightBarButtonItem = photoItem

        let refreshItem = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(doRefresh))
        refreshItem.tintColor = .black.withAlphaComponent(0.7)
        navigationItem.leftBarButtonItem = refreshItem
    }

    @objc
    func checkPermission() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            DispatchQueue.main.async {
                self.showGallery()
            }

        case .denied:
            DispatchQueue.main.async {
                self.showAuthorizationDeniedAlert()
            }
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                self.checkPermission()
            }
        default:
            break
        }
    }

    private func showAuthorizationDeniedAlert() {
        let uiAlertController = UIAlertController(title: "접근 권한 오류", message: "사진첩의 접근 권한을 활성화 해주세요.", preferredStyle: .alert)
        uiAlertController.addAction(UIAlertAction(title: "닫기", style: .cancel))
        uiAlertController.addAction(UIAlertAction(title: "설정으로 가기", style: .default) { action in

            guard let url: URL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(url) {
                print(url)
                UIApplication.shared.open(url)
            }
        })

        present(uiAlertController, animated: true)
    }

    /**
     사진첩을 띄우게 하는 로직
     */
    func showGallery() {
        let photoLibrary = PHPhotoLibrary.shared()
        var configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        configuration.selectionLimit = 10

        let phPickerViewController = PHPickerViewController(configuration: configuration)
        phPickerViewController.delegate = self
        present(phPickerViewController, animated: true)
    }

    @objc
    func doRefresh() {
        photoCollectionView.reloadData()
    }


}


//#### EXTENSION ####//

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        fetchAssets?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell

        if let phAsset: PHAsset = fetchAssets?[indexPath.row] {
            photoCell.loadImage(phAsset: phAsset)
        }
        return photoCell
    }
}


extension ViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController,
                didFinishPicking results: [PHPickerResult]) {
        let identifierList: [String] = results.map {
            $0.assetIdentifier ?? ""
        }

        fetchAssets = PHAsset.fetchAssets(withLocalIdentifiers: identifierList, options: nil)

        photoCollectionView.reloadData()

        dismiss(animated: true)
    }

}
