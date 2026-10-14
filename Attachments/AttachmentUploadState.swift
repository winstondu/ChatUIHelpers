//
//  AttachmentUploadState.swift
//  Winston
//
//  Created on 1/2/26.
//

import Foundation

public enum AttachmentUploadState: Equatable {
    case pending
    case uploading
    case completed(cdnURL: URL)
    case failed(Error)

    public static func == (lhs: AttachmentUploadState, rhs: AttachmentUploadState) -> Bool {
        switch (lhs, rhs) {
        case (.pending, .pending), (.uploading, .uploading):
            return true
        case (.completed(let a), .completed(let b)):
            return a == b
        case (.failed, .failed):
            return true
        default:
            return false
        }
    }
}
