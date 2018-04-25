//
//  TagInfo+CoreDataProperties.swift
//  
//
//
//

import Foundation
import CoreData


extension TagInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TagInfo> {
        return NSFetchRequest<TagInfo>(entityName: "TagInfo")
    }

    @NSManaged public var isPersonalTag: Bool
    @NSManaged public var isRecordingPageTag: Bool
    @NSManaged public var tagImageData: NSData?
    @NSManaged public var tagImageName: String?
    @NSManaged public var tagIndex: Int64
    @NSManaged public var tagName: String?
    @NSManaged public var tagSecondValue: Int64
    @NSManaged public var tagToRecording: NSSet?

}

// MARK: Generated accessors for tagToRecording
extension TagInfo {

    @objc(addTagToRecordingObject:)
    @NSManaged public func addToTagToRecording(_ value: RecVideoClips)

    @objc(removeTagToRecordingObject:)
    @NSManaged public func removeFromTagToRecording(_ value: RecVideoClips)

    @objc(addTagToRecording:)
    @NSManaged public func addToTagToRecording(_ values: NSSet)

    @objc(removeTagToRecording:)
    @NSManaged public func removeFromTagToRecording(_ values: NSSet)

}
