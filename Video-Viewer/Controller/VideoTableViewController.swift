//
//  VideoTableViewController.swift
//  Video-Viewer
//
//  Created by karlis.stekels on 22/04/2021.
//

import UIKit

class VideoTableViewController: UITableViewController {
    
    //MARK: - Properties
    private let videoCellID                 = "VideoCell"
    private let detailedViewStoryboardID    = "DetailedView"
    private let urlString                   = "https://iphonephotographyschool.com/test-api/videos"
    private var videoSource                 = [Video]()
    private var picturesPathExists          = Bool()
    private var imageDataArray: [Data]      = []
    private var progressCounter: Int        = 0
    private let progressBarItem             = UIProgressView()
    private let activityIndicator           = UIActivityIndicatorView()
    private var numberOfLocalPictures: Int  = 0
    private var refressIsActive             = false
    
    
    
    //MARK: - Main
    override func viewDidLoad() {
        super.viewDidLoad()
        print(getDocumentDirectory())
        initialSetUp()
        countPictures()
        loadContent()
    }
    
    // Switch between local and remote
    private func loadContent() {
        if picturesPathExists {
            print("--------- Local ---------")
            readLocalJson()
        }else {
            print("--------- Remote ---------")
            getData(for: urlString)
            addSubviewOnTop()
        }
    }
    
    // Count Pictures In Documents/Pictures
    private func countPictures() {
        if let numOfPic = countPicturesInLocalDirectory() {
            numberOfLocalPictures = numOfPic
            print(numberOfLocalPictures)
        }
    }
    
    // Add Progress bar and Activity indicator
    private func addSubviewOnTop() {
        
        // Screen Parameters
        let screenWidth = view.frame.size.width
        let screenHeight = view.frame.size.height
        print("Width: \(screenWidth), Height: \(screenHeight)")
        //MARK: - Progress bar
        self.view.addSubview(progressBarItem)
        progressBarItem.isHidden = true
        progressBarItem.backgroundColor = UIColor.systemGray
        progressBarItem.progressViewStyle = .bar
        progressBarItem.sizeToFit()
        progressBarItem.alpha = 0.7
        progressBarItem.progressTintColor = .systemBlue
        progressBarItem.transform = CGAffineTransform(scaleX: 1, y: 4)
        self.navigationItem.titleView = progressBarItem
        
        self.view.addSubview(activityIndicator)
        activityIndicator.isHidden = true
        activityIndicator.frame = CGRect(x: screenWidth / 2 - 25, y: screenHeight / 2 - 150, width: 50, height: 50)
        activityIndicator.color = .systemGray2
        activityIndicator.style = .large
    }
    
    
}

//MARK: - Table View
extension VideoTableViewController {
    
    // numberOfRowsInSection
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if numberOfLocalPictures > 0 {
            return numberOfLocalPictures
        } else {
            return imageDataArray.count
        }
        
    }
    
    // cellForRowAt
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if let videoCell = tableView.dequeueReusableCell(withIdentifier: videoCellID, for: indexPath) as? VideoTableViewCell {
            
            if videoCell.imageView?.image != nil {
                videoCell.spinner.stopAnimating()
                videoCell.spinner.isHidden = true
            } else {
                videoCell.spinner.isHidden = false
                videoCell.spinner.startAnimating()
            }
            

            videoCell.thumbnailImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            videoCell.thumbnailImageView.alpha = 0.5

            
            
            DispatchQueue.main.async {
                videoCell.thumbnailImageView.image = self.getLocalImage(imageName: "\(indexPath.row).jpeg").resizedImage(with: CGSize(width: 50.0, height: 50.0))
                self.title = "Videos"
            }

            
            
            UIView.animate(withDuration: 0.8, delay: 0.35, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
                videoCell.thumbnailImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                videoCell.thumbnailImageView.alpha = 1

            })

    
            videoCell.labelText.text = videoSource[indexPath.row].name
            videoCell.thumbnailImageView.layer.cornerRadius = 20
            cell = videoCell
            
        }
        return cell
    }
    
    
    // didSelectRowAt
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(identifier: detailedViewStoryboardID) as? DetailedViewController else { return }
        print(indexPath)
        
        vc.txt = videoSource[indexPath.row].name
        vc.dscr = videoSource[indexPath.row].description
        vc.img = getLocalImage(imageName: "\(indexPath.row).jpeg")
        vc.videoURL = videoSource[indexPath.row].video_link
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
}


//MARK: - Methodes - Working With Internet URL
extension VideoTableViewController {
    
    //MARK: - Refresh swipe
    @objc func refreshTableVIew() {
        refressIsActive = true
        numberOfLocalPictures = 0
        imageDataArray = []
        self.title = ""
        progressBarItem.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        getData(for: urlString)
    }
    
    //MARK: - Initial set-Up
    private func initialSetUp() {
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = ""
        
        // Tablview swipe down - refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTableVIew), for: .valueChanged)
        self.refreshControl = refreshControl
        
        // Check, if Pictures Folder exist
        picturesPathExists = getDocumentDirectory().appendingPathComponent("Pictures").hasDirectoryPath
    }
    
    // Get Data from URl request
    private func getData(for urlString: String) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let result = try JSONDecoder().decode(Videos.self, from: data)
                        print(result.videos)
                        
                        // Save JSON data to User Documents/Source folder
                        self.createFileToURL(withData: data, withName: "videos.json", withSubDirectory: "Source")
                        
                        self.parse(json: data)
                    } catch {
                        print("Error message: \(error)")
                    }
                }
            }.resume()
        }
    }
    
    // Parse JSON data and update tanbleView cells
    private func parse(json: Data) {
        if let jsonData = try? JSONDecoder().decode(Videos.self, from: json) {
            videoSource = jsonData.videos
            
            //Create picture
            DispatchQueue.global().async {
                self.createImageFromJson()
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }else {
            print("Parsing error")
        }
    }
    
}


//MARK: - Methodes - Working with Local files
extension VideoTableViewController {
    
    // Document Directory path
    private func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // Pictures Directory path (Count pictures)
    private func countPicturesInLocalDirectory() -> Int? {
        let fileManager = FileManager.default
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let picturesPath = documentPath + "/Pictures"
        let dirContents = try? fileManager.contentsOfDirectory(atPath: picturesPath)
        let count = dirContents?.count
        print("Pictures in Local directory = \(count ?? 0 - 1)")
        guard let numOfPicture = count else {
            return 0
        }
        return numOfPicture - 1
    }
    
    //MARK: - Create File/Directory
    
    // Create new Directory
    private func createDirectory(withFolderName dest: String, toDirectory directory: FileManager.SearchPathDirectory = .documentDirectory) {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: directory, in: .userDomainMask)
        if let applicationSupportURL = urls.last {
            do {
                var newURL = applicationSupportURL
                newURL = newURL.appendingPathComponent(dest, isDirectory: true)
                try fileManager.createDirectory(at: newURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("error \(error)")
            }
        }
    }
    
    // Create a file to URL
    private func createFileToURL(withData data: Data?, withName name: String, withSubDirectory subdir: String, toDirectory directory: FileManager.SearchPathDirectory = .documentDirectory) {
        let fileManager = FileManager.default
        let destPath = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        createDirectory(withFolderName: subdir, toDirectory: directory)
        if let fullDestPath = destPath?.appendingPathComponent(subdir + "/" + name), let data = data {
            do {
                try data.write(to: fullDestPath, options: .atomic)
            } catch {
                print("error \(error)")
            }
        }
    }
    
    // Create .jpeg Images from thumbnail links
    private func createImageFromJson() {
        
        // Check for refresh swipe
        if !refressIsActive {
            refressIsActive = false
            
            // check, if pictures are in local directory
            if numberOfLocalPictures > 0 {
                return
            }
        }
        
        // When loading images to memory
        DispatchQueue.main.async {
            self.title = ""
        }
        
        for index in 0..<videoSource.count {
            if let thumbnailURL = URL(string: videoSource[index].thumbnail) {
                if let imgData = try? Data(contentsOf: thumbnailURL) {
                        
                    print("Image data array count (Start)-> \(imageDataArray.count)")
                    
                    if !imageDataArray.contains(imgData) {
                        imageDataArray.append(imgData)
                        progressCounter += 1
                    }

                }

            }

            
            //MARK: - ChildView Animation
            DispatchQueue.main.async {
                

                self.progressBarItem.progress = Float(self.progressCounter) / 10
                    if self.progressBarItem.isHidden {
                        self.progressBarItem.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
                        self.progressBarItem.isHidden = false
                        self.activityIndicator.isHidden = false
                        self.activityIndicator.startAnimating()
                        
                        UIProgressView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: [], animations: {
                            if !self.progressBarItem.isHidden {
                                self.progressBarItem.transform = CGAffineTransform(scaleX: 1, y: 1)
                            }
                        })
                    }
                    print("Progress : \(self.progressBarItem.progress)")
            }
            
        }
        DispatchQueue.global().async {
            self.createWithoutDuplicates()
        }

        
    }
    
    // Create Images avoiding duplicates
    private func createWithoutDuplicates() {
        
        for index in 0..<self.imageDataArray.count {
            let imageToSave = UIImage(data: self.imageDataArray[index])
            self.saveImage(img: imageToSave, number: index)
        }
        print("Count: \(imageDataArray.count)")
        DispatchQueue.main.async {
            // Subview hidden
            self.progressBarItem.removeFromSuperview()
            self.activityIndicator.removeFromSuperview()
            self.title = "Videos"
            
            self.progressCounter = 0
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()

        }
        
    }
    
    // Save image to Documents/Pictures/ *.jpeg
    private func saveImage(img: UIImage?, number: Int) {
        if let image = img {
            if let data = image.jpegData(compressionQuality: 0.4) {
                createDirectory(withFolderName: "Pictures")
                let filename = getDocumentDirectory().appendingPathComponent("Pictures").appendingPathComponent("\(number).jpeg")
                try? data.write(to: filename)
            }
        }
    }
    
    //MARK: - Read files
    
    // Read local JSON file from Documents/Source/videos.json
    private func readLocalJson() {
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let jsonFilePath = documentsURL.appendingPathComponent("Source").appendingPathComponent("videos.json")
            if let textContent = try? String(contentsOf: jsonFilePath, encoding: .utf8) {
                let data = Data(textContent.utf8)
                parse(json: data)
            }
        }
    }
    
    // Read local image and return UIImage
    private func getLocalImage(imageName: String) -> UIImage {
        guard let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return UIImage(systemName: "icloud.circle")!
        }
        let fileURL = filePath.appendingPathComponent("Pictures").appendingPathComponent(imageName)
        
        do {
            let imageData = try Data(contentsOf: fileURL)
            if let newImage = UIImage(data: imageData) {
                return newImage
            }
        } catch {
            print("No Image to show")
        }
        return UIImage(systemName: "icloud.circle")!
    }
    
}
