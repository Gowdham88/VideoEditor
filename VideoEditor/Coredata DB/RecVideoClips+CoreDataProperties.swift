//
//  RecVideoClips+CoreDataProperties.swift
//  
//
//
//

import Foundation
import CoreData


extension RecVideoClips {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecVideoClips> {
        return NSFetchRequest<RecVideoClips>(entityName: "RecVideoClips")
    }

    @NSManaged public var clipDuration: Int64
    @NSManaged public var clipEndTime: Int64
    @NSManaged public var clipName: String?
    @NSManaged public var teamName: String?
    @NSManaged public var clipNumber: Int64
    @NSManaged public var clipSecond: Int64
    @NSManaged public var clipStartTime: Int64
    @NSManaged public var clipTagSecond: Int64
    @NSManaged public var videoFolderID: String?
    @NSManaged public var recordingToTagList: NSSet?
    @NSManaged public var isHighlightClip: Bool
    @NSManaged public var clipDate: NSDate?
    @NSManaged public var isPostClip: Bool
    @NSManaged public var fbLive: Bool

}

// MARK: Generated accessors for recordingToTagList
extension RecVideoClips {

    @objc(addRecordingToTagListObject:)
    @NSManaged public func addToRecordingToTagList(_ value: TagInfo)

    @objc(removeRecordingToTagListObject:)
    @NSManaged public func removeFromRecordingToTagList(_ value: TagInfo)

    @objc(addRecordingToTagList:)
    @NSManaged public func addToRecordingToTagList(_ values: NSSet)

    @objc(removeRecordingToTagList:)
    @NSManaged public func removeFromRecordingToTagList(_ values: NSSet)

}
