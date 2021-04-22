//
//  Videos.swift
//  Video-Viewer
//
//  Created by karlis.stekels on 22/04/2021.
//

import Foundation
struct Videos: Decodable {
    var videos: [Video]
}

struct Video: Decodable {
    var name: String
    var thumbnail: String
    var description: String
    var video_link: String
}
