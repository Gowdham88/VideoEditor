//
//  RecEventList+CoreDataProperties.swift
//  
//
//
//

import Foundation
import CoreData


extension RecEventList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecEventList> {
        return NSFetchRequest<RecEventList>(entityName: "RecEventList")
    }

    @NSManaged public var awayTeamScore: Int64
    @NSManaged public var homeTeamScore: Int64
    @NSManaged public var sportName: String?
    @NSManaged public var eventName: String?
    @NSManaged public var isDayEvent: Bool
    @NSManaged public var homeTeamName: String?
    @NSManaged public var awayTeamName: String?
    @NSManaged public var homeTeamLogo: NSData?
    @NSManaged public var awayTeamLogo: NSData?
    @NSManaged public var videoFolderID: String?
    @NSManaged public var videoPreset: String?
    @NSManaged public var recordingDate: NSDate?

}
