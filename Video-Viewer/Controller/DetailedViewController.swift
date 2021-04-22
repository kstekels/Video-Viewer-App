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
        
        detailedTextLabel.text = txt
        detailedTextDescription.text = dscr
        detailedImageView.image = img
        detailedImageView.layer.cornerRadius = 10

    }

    @IBAction func playButtonTappped(_ sender: UIButton) {
        guard let url = URL(string: videoURL) else { return }
        let player = AVPlayer(url: url)
        let controller = AVPlayerViewController()
        controller.player = player
        present(controller, animated: true, completion: nil)
        player.play()
    }
}
