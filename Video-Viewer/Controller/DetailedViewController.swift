//
//  DetailedViewController.swift
//  Video-Viewer
//
//  Created by karlis.stekels on 22/04/2021.
//

import UIKit
import AVKit

class DetailedViewController: UIViewController, AVAssetDownloadDelegate {
    
    @IBOutlet var detailedTextLabel: UILabel!
    @IBOutlet var detailedImageView: UIImageView!
    @IBOutlet var detailedTextDescription: UITextView!
    
    private let streamID    = "videoStream2"
    
    var img: UIImage?
    var txt: String         = ""
    var dscr: String        = ""
    var videoURL: String    = ""
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        initialSetUp()
        createDownlaodButton()
        animateImage()
        
    }
    
    // Create Downlaod button
    private func createDownlaodButton() {
        let availableOffline = checkIfOfflineVideoAccessible()
        if !availableOffline {
            let downloadButton = UIBarButtonItem(image: UIImage(systemName: "icloud.and.arrow.down"), style: UIBarButtonItem.Style.done, target: self, action: #selector(downloadButtonTapped))
            navigationItem.rightBarButtonItem = downloadButton
        }
    }
    
    //MARK: - Downlaod video
    @objc func downloadButtonTapped() {
        
        let ac = UIAlertController(title: "Download video?", message: "Press 'Downlaod' to save video on your device!", preferredStyle: .actionSheet)
        let downloadAction = UIAlertAction(title: "Download", style: .default) { [self] _ in
            
            let hlsAsset = AVURLAsset(url: URL(string: videoURL)!)
            let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: streamID)
            let assetURLSession = AVAssetDownloadURLSession(configuration: backgroundConfiguration, assetDownloadDelegate: self, delegateQueue: OperationQueue.main)
            
            // Downlaod
            let assetDownloadTask = assetURLSession.makeAssetDownloadTask(asset: hlsAsset, assetTitle: "MyVideo", assetArtworkData: nil, options: nil)
            
            assetDownloadTask?.resume()
            
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        ac.addAction(downloadAction)
        ac.addAction(cancelAction)
        
        present(ac, animated: true, completion: nil)
    }

    
    
    //MARK: - URL session
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        var percentComplete = 0.0
        for value in loadedTimeRanges {
            let loadedTimeRange: CMTimeRange = value.timeRangeValue
            percentComplete += CMTimeGetSeconds(loadedTimeRange.duration) / CMTimeGetSeconds(timeRangeExpectedToLoad.duration)
        }
        percentComplete *= 100
        print("percent complete: \(percentComplete)")

        DispatchQueue.main.async {
            self.title = "Downloaded: \(Int(percentComplete.rounded())) %"
        }
        
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if error != nil {
            print("Download Completed!")
            self.title = "Saved!"
        } else {
            print("urlSession didCompleteWithError \(String(describing: error))")
        }
        
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        print("Video location -> \(location)")
        UserDefaults.standard.set(location.relativePath, forKey: "assetPath")
        
    }
    
    
    // Play button Action
    @IBAction func playButtonTappped(_ sender: UIButton) {
        
        let offlineVideoCheck = checkIfOfflineVideoAccessible()
        if offlineVideoCheck {
            print("Playing OFFLINE Video")
            playOffline()
        } else {
            print("Playing ONLINE Video")
            playOnline()
        }
        
    }
    
    // Offline player
    private func playOffline() {
        guard let assetPath = UserDefaults.standard.value(forKey: "assetPath") as? String else {
            print("No offline media is available")
            return
        }
        let baseURL = URL(fileURLWithPath: NSHomeDirectory())
        let assetURL = baseURL.appendingPathComponent(assetPath)
        let asset = AVURLAsset(url: assetURL)
        if let cache = asset.assetCache, cache.isPlayableOffline {
            let playerItem = AVPlayerItem(asset: asset)
            
            let player = AVPlayer(playerItem: playerItem)
            let controller = AVPlayerViewController()
            controller.player = player
            present(controller, animated: true) {
                controller.player?.play()
            }
            
        } else {
            print("Offline player ERROR")
        }
    }
    
    // online player
    private func playOnline() {
        guard let url = URL(string: videoURL) else { return }
        let player = AVPlayer(url: url)
        let controller = AVPlayerViewController()
        controller.player = player
        present(controller, animated: true) {
            controller.player?.play()
        }
    }
    
    
}

extension DetailedViewController {
    //MARK: - Set-Up
    private func initialSetUp() {
        // Navigation bar
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        // Text
        detailedTextLabel.text = txt
        detailedTextLabel.font = .systemFont(ofSize: 28, weight: .bold)
        detailedTextDescription.text = dscr
        detailedTextDescription.font = .systemFont(ofSize: 16, weight: .regular)
        // Image
        detailedImageView.image = img
        detailedImageView.alpha = 0.5
        detailedImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        detailedImageView.layer.cornerRadius = 10
        
        
    }
    
    // Image Animation
    private func animateImage() {
        UIView.animate(withDuration: 1.5, delay: 0.35, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: [], animations: {
            self.detailedImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.detailedImageView.alpha = 1
        })
    }
    
    // Check, if offline video available
    private func checkIfOfflineVideoAccessible() -> Bool {
        guard let assetPath = UserDefaults.standard.value(forKey: "assetPath") as? String else {
            print("No offline media is available")
            return false
        }
        let baseURL = URL(fileURLWithPath: NSHomeDirectory())
        let assetURL = baseURL.appendingPathComponent(assetPath)
        let asset = AVURLAsset(url: assetURL)
        if let cache = asset.assetCache, cache.isPlayableOffline {
            
            print("AVAILABLE OFFLINE -------")
            self.navigationItem.rightBarButtonItem?.isEnabled = false

            return true
            
        }
        return false
    }
    
}
