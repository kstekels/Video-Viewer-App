//
//  VideoTableViewController.swift
//  Video-Viewer
//
//  Created by karlis.stekels on 22/04/2021.
//

import UIKit

class VideoTableViewController: UITableViewController {
    
    //MARK: - Properties
    private let videoCellID = "VideoCell"
    private let detailedViewStoryboardID = "DetailedView"
    private let urlString = "https://iphonephotographyschool.com/test-api/videos"
    private var videoSource = [Video]()
    private var picturesPathExists = Bool()
    private var imageDataArray: [Data] = []

    
    
    //MARK: - Main
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picturesPathExists = getDocumentDirectory().appendingPathComponent("Pictures").hasDirectoryPath
        
        initialSetUp()
        
        //MARK: - test
        if picturesPathExists {
            readLocalJson()
        } else {
            getData(for: urlString)
        }
        
        print(getDocumentDirectory())
    }
    
    
}

//MARK: - Table View
extension VideoTableViewController {
    
    //numberOfRowsInSection
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageDataArray.count
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
    
    @objc func refreshTableVIew() {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    // Initial Set-up parameters
    private func initialSetUp() {
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Videos"
        
        // Tablview swipe down - refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTableVIew), for: .valueChanged)
        self.refreshControl = refreshControl
        
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
            
            // Create Img
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
        for index in 0..<videoSource.count {
            if let thumbnailURL = URL(string: videoSource[index].thumbnail) {
                if let imgData = try? Data(contentsOf: thumbnailURL) {
                        
                    print(imageDataArray.count)
                    
                    if !imageDataArray.contains(imgData) {
                        imageDataArray.append(imgData)
                    }
                }
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
            self.tableView.reloadData()
        }
        
    }
    
    // Save image to Documents/Pictures/ *.jpeg
    private func saveImage(img: UIImage?, number: Int) {
        if let image = img {
            if let data = image.jpegData(compressionQuality: 0.0) {
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
