//
//  RecordingInfo.swift
//  VideoEditor
//
//  Copyright © 2018 Ark Inc. All rights reserved.
//

import Foundation


class RecordingInfo: NSObject {

    var sportName: String = ""
    var eventName: String = ""
    
    var homeTeamName: String = ""
    var awayTeamName: String = ""
    
    var videoFolderName: String = ""
    
    var isDayEvent: Bool = true
    
    var homeTeamLogo: UIImage? = nil
    var awayTeamLogo: UIImage? = nil
    
    var awayTeamScore: Int64 = 0
    var homeTeamScore: Int64 = 0

}

