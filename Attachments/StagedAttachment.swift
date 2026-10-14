//
//  StagedAttachment.swift
//  Winston
//
//  Created on 1/2/26.
//

import SwiftUI

public protocol StagedAttachment: Identifiable, Equatable {
    associatedtype ThumbnailView: View

    var id: UUID { get }

    var isUploading: Bool { get }

    @MainActor @ViewBuilder
    func makeThumbnailView() -> ThumbnailView
}
