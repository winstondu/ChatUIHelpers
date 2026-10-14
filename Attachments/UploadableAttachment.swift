//
//  UploadableAttachment.swift
//  Winston
//
//  Created on 1/2/26.
//

import Observation

public protocol UploadableAttachment: AnyObject, Observable {
    var isUploading: Bool { get }
    var isFailed: Bool { get }
    var uploadProgress: Double { get }

    @MainActor
    func retry()
}
