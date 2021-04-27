//
//  DetailedViewController.swift
//  Video-Viewer
//
//  Created by karlis.stekels on 22/04/2021.
//

import UIKit
import AVKit

class DetailedViewController: UIViewController {
    
    @IBOutlet var detailedTextLabel: UILabel!
    @IBOutlet var detailedImageView: UIImageView!
    @IBOutlet var detailedTextDescription: UITextView!
    
    var img: UIImage?
    var txt: String = ""
    var dscr: String = ""
    var videoURL: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetUp()
        
        animateImage()

    }

    @IBAction func playButtonTappped(_ sender: UIButton) {
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
    
    private func initialSetUp() {
        // Text
        detailedTextLabel.text = txt
        detailedTextDescription.text = dscr
        // Image
        detailedImageView.image = img
        detailedImageView.alpha = 0.5
        detailedImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        detailedImageView.layer.cornerRadius = 10
    }
    
    private func animateImage() {
        UIView.animate(withDuration: 1.5, delay: 0.35, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: [], animations: {
            self.detailedImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.detailedImageView.alpha = 1
        })
    }
    
}
