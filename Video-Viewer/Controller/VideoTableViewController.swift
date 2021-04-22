//
//  VideoTableViewController.swift
//  Video-Viewer
//
//  Created by karlis.stekels on 22/04/2021.
//

import UIKit

class VideoTableViewController: UITableViewController {
    
    private let videoCellID = "VideoCell"
    private let urlString = "https://iphonephotographyschool.com/test-api/videos"
    
    private var videoSource = [Video]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
        getData(for: urlString)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if let videoCell = tableView.dequeueReusableCell(withIdentifier: videoCellID, for: indexPath) as? VideoTableViewCell {
            let source = videoSource[indexPath.row]
            
            videoCell.labelText.text = source.name
            
            if let imageURL = URL(string: videoSource[indexPath.row].thumbnail) {
                if let imgData = try? Data(contentsOf: imageURL) {
                    videoCell.thumbnailImageView.image = UIImage(data: imgData)?.resizedImage(with: CGSize(width: 80.0, height: 80.0))
                }
            }
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
    
}
