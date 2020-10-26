//
//  ImagePickerViewController.swift
//  Debugger
//
//  Created by Gerry Low on 2020-06-27.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit
import CoreData

class ImagePickerViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionBarButton: UIBarButtonItem!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var dimmer: UIView!
    @IBOutlet weak var downloadingIndicator: UIStackView!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<BGImage>!
    var currentSessionTask: URLSessionTask?
    var downloadsFinished = false
    
    // set the number of photos to download if available for each collection
    let perPage = 30
    
    // set the compression quality for converting downloaded images to data for storing
    let compressionQuality: CGFloat = 0.7
    
    // set the desired layout for collection view
    let approximateDimensionForCellsInPhone:Int = 120
    let approximateDimensionForCellsInPad:Int = 150
    let spacingForCells: CGFloat = 2.0
    let collectionViewInset: CGFloat = 5.0
    
    var approximateDimensionForCells: Int {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return approximateDimensionForCellsInPad
        }
        else if UIDevice.current.userInterfaceIdiom == .phone {
            return approximateDimensionForCellsInPhone
        }
        else {
            assert(false, "The user is using an unrecognized device")
            return approximateDimensionForCellsInPhone
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        registerCollectionViewCells()
        checkStoredImages()
        setupBackgroundForDownloadingIndicator()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        flowLayoutAdjustment(width: view.safeAreaLayoutGuide.layoutFrame.width)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentSessionTask?.cancel()
    }
    
    private func registerCollectionViewCells() {
        let cell = UINib(nibName: "ImageCell", bundle: nil)
        collectionView.register(cell, forCellWithReuseIdentifier: "ImageCell")
    }
    
    private func flowLayoutAdjustment(width: CGFloat) {
        if isViewLoaded {
            let numberOfItemsInRow: Int = Int(width) / approximateDimensionForCells
            let dimension: CGFloat = (width - collectionViewInset * 2) / CGFloat(numberOfItemsInRow) - spacingForCells
            flowLayout.sectionInset = .init(top: collectionViewInset, left: collectionViewInset, bottom: collectionViewInset,right: collectionViewInset)
            flowLayout.minimumInteritemSpacing = spacingForCells
            flowLayout.minimumLineSpacing = spacingForCells
            flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        }
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<BGImage> = BGImage.fetchRequest()
        let sortById = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortById]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "bgimages")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    private func setupBackgroundForDownloadingIndicator() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.layer.borderColor = UIColor.black.cgColor
        backgroundView.layer.borderWidth = 1
        
        // put background view as the most background subviews of stack view
        downloadingIndicator.insertSubview(backgroundView, at: 0)
        
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: downloadingIndicator.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: downloadingIndicator.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: downloadingIndicator.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: downloadingIndicator.bottomAnchor)
        ])
    }
    
    private func checkStoredImages() {
        let numberOfObjects = fetchedResultsController.sections?[0].numberOfObjects ?? 0
        if numberOfObjects > 0 {
            let imagesToBeDisplayed = numberOfObjects
            var imagesToBeDownloaded = 0
            var imagesInStorage = 0
            for index in 0...(numberOfObjects - 1) {
                let bgImage = fetchedResultsController.sections?[0].objects?[index] as! BGImage
                if bgImage.webformatImage != nil {
                    imagesInStorage += 1
                } else {
                    imagesToBeDownloaded += 1
                    PixabayClient.getImage(imageURL: bgImage.webformatURL!) { (image, error) in
                        // "if" is used here instead of "guard" since "imagesToBeDownloaded" still need to be counted regardless of the result of the download
                        if let image = image {
                            DispatchQueue.global(qos: .utility).sync {
                                bgImage.webformatImage = image.jpegData(compressionQuality: self.compressionQuality)
                                try? self.dataController.save()
                            }
                        } else {
                            // fail silently
                        }
                        imagesToBeDownloaded -= 1
                        if imagesToBeDownloaded == 0 {
                            self.downloadsFinished = true
                            if self.dimmer.isHidden {
                                self.newCollectionBarButton.isEnabled = true
                            }
                        }
                    }
                }
            }
            if imagesInStorage == imagesToBeDisplayed {
                downloadsFinished = true
                if dimmer.isHidden {
                    newCollectionBarButton.isEnabled = true
                }
            }
        } else {
            getImageCollection()
        }
    }
    
    private func getImageCollection() {
        var numberOfObjects = fetchedResultsController.sections?[0].numberOfObjects ?? 0
        var page = 1
        if numberOfObjects > 0 {
            let bgImage = fetchedResultsController.sections?[0].objects?[0] as! BGImage
            let totalPages = Int(bgImage.total) / perPage
            if totalPages > 1 {
                page = Int.random(in: 1...8)
            }
            while numberOfObjects > 0 {
                let bgImageToBeDeleted = fetchedResultsController.sections?[0].objects?[0] as! BGImage
                dataController.viewContext.delete(bgImageToBeDeleted)
                try? dataController.save()
                numberOfObjects = fetchedResultsController.sections?[0].numberOfObjects ?? 0
            }
        }
        noImagesLabel.isHidden = true
        PixabayClient.searchBackgroundPhotos(page: page, perPage: perPage, completion: handleImageSearchResponse(imageList:error:))
    }
    
    private func handleImageSearchResponse(imageList: ImageSearchResponse?, error: Error?) {
        guard let imageList = imageList else {
            showAlert(title: "Downloading Images Failed", message: error?.localizedDescription, on: self)
            return
        }
        if imageList.hits.count > 0 {
            for bgImage in imageList.hits {
                let newBGImage = BGImage(context: dataController.viewContext)
                newBGImage.id = Int64(bgImage.id)
                newBGImage.total = Int64(imageList.total)
                newBGImage.webformatURL = bgImage.webformatURL
                newBGImage.largeImageURL = bgImage.largeImageURL
            }
            try? dataController.save()
            checkStoredImages()
        } else {
            noImagesLabel.isHidden = false
            newCollectionBarButton.isEnabled = true
        }
    }
    
    @IBAction func newCollectionBarButtonTapped(_ sender: Any) {
        showAlertOKCancel(title: "New Collection", message: "Fetching a new collection will remove all images in this collection, continue?", on: self, completion: handleNewCollectionRequest)
    }
    
    @IBAction func cancelBarButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func handleNewCollectionRequest() {
        newCollectionBarButton.isEnabled = false
        getImageCollection()
    }
    
}

extension ImagePickerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let bgImage = fetchedResultsController.object(at: indexPath)
        if let imageData = bgImage.webformatImage, let image = UIImage(data: imageData) {
            cell.setImage(image)
        } else {
            cell.setImage(UIImage(named: "Debugging")!)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bgImage = fetchedResultsController.object(at: indexPath)
        if bgImage.webformatImage != nil {
            newCollectionBarButton.isEnabled = false
            dimmer.isHidden = false
            downloadingIndicator.isHidden = false
            currentSessionTask = PixabayClient.getImage(imageURL: bgImage.largeImageURL!) { (image, error) in
                guard let image = image else {
                    self.dimmer.isHidden = true
                    self.downloadingIndicator.isHidden = true
                    self.newCollectionBarButton.isEnabled = self.downloadsFinished
                    self.showAlert(title: "Download Failed", message: error?.localizedDescription, on: self)
                    return
                }
                let presentingVC = (self.presentingViewController as! UINavigationController).topViewController as! LevelMakerViewController
                presentingVC.bgImage = image
                presentingVC.updateBGImage()
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            showAlert(title: "Image Not Loaded", message: "This image is still being downloaded. Please try again later.", on: self)
        }
    }
    
}

extension ImagePickerViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert: collectionView.insertItems(at: [newIndexPath!])
        case .delete: collectionView.deleteItems(at: [indexPath!])
        case .update: collectionView.reloadItems(at: [indexPath!])
        default: fatalError("Invalid change type in controller(_:didChange:at:for:newIndexPath:). Only .insert, .update and .delete should be possible.")
        }
    }
    
}
