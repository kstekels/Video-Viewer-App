//
//  VideoTableViewController.swift
//  Video-Viewer
//
//  Created by karlis.stekels on 22/04/2021.
//

import UIKit

class VideoTableViewController: UITableViewController {
    
    private let videoCellID = "VideoCell"
    private let detailedViewStoryboardID = "DetailedView"
    private let urlString = "https://iphonephotographyschool.com/test-api/videos"
    
    private  var thumbImage: [UIImage?] = [UIImage?]()
    
    private var videoSource = [Video]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        if videoSource.isEmpty {
            getData(for: urlString)
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTableVIew), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    @objc func refreshTableVIew() {
        thumbImage = []
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if let videoCell = tableView.dequeueReusableCell(withIdentifier: videoCellID, for: indexPath) as? VideoTableViewCell {
            let source = videoSource[indexPath.row]

            if videoCell.imageView?.image != nil {
                videoCell.spinner.stopAnimating()
                videoCell.spinner.isHidden = true
            } else {
                videoCell.spinner.isHidden = false
                videoCell.spinner.startAnimating()
            }
            
            DispatchQueue.global().async { [weak self] in
                if let imageURL = URL(string: (self?.videoSource[indexPath.row].thumbnail)!) {
                    if let imgData = try? Data(contentsOf: imageURL) {
                        DispatchQueue.main.async {

                            videoCell.thumbnailImageView.image = UIImage(data: imgData)?.resizedImage(with: CGSize(width: 80.0, height: 80.0))
                            videoCell.thumbnailImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                            videoCell.thumbnailImageView.alpha = 0.5
                            
                            UIView.animate(withDuration: 0.8, delay: 0.35, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
                                videoCell.thumbnailImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                                videoCell.thumbnailImageView.alpha = 1
                                
                            })
                            
                            self?.thumbImage.append(UIImage(data: imgData))
                        }
                    }
                }
            }
            
            videoCell.labelText.text = source.name
            videoCell.thumbnailImageView.layer.cornerRadius = 10
                        
            cell = videoCell
        }
        
        return cell
    }
    
    private func getData(for urlString: String) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let result = try JSONDecoder().decode(Videos.self, from: data)
                        print(result.videos)
                        self.parse(json: data)
                    } catch {
                        print("Error message: \(error)")
                    }
                }
            }.resume()
        }
    }
    
    private func parse(json: Data) {
        if let jsonData = try? JSONDecoder().decode(Videos.self, from: json) {
            videoSource = jsonData.videos
            print("Video data source ->>>>>> \(videoSource)")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }else {
            print("Parsing error")
        }
    }
    
    func initialSetUp() {
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Videos"
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(identifier: detailedViewStoryboardID) as? DetailedViewController else { return }
        vc.txt = videoSource[indexPath.row].name
        vc.dscr = videoSource[indexPath.row].description
        vc.img = thumbImage[indexPath.row]
        vc.videoURL = videoSource[indexPath.row].video_link
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
