//
//  ContextMenuPlusButton.swift
//  Winston
//
//  Created on 12/8/25.
//

import SwiftUI

public struct ContextMenuPlusButton: View {
    let presentation: ContextMenuPresentation
    let menuId: String
    var size: CGFloat = 40
    var alternateIcon: Image? = nil
    var backgroundColor: Color = Color.white.opacity(0.15)
    var plusIcon: Image = Image(systemName: "plus")

    public init(
        presentation: ContextMenuPresentation,
        menuId: String,
        size: CGFloat = 40,
        alternateIcon: Image? = nil,
        backgroundColor: Color = Color.white.opacity(0.15),
        plusIcon: Image = Image(systemName: "plus")
    ) {
        self.presentation = presentation
        self.menuId = menuId
        self.size = size
        self.alternateIcon = alternateIcon
        self.backgroundColor = backgroundColor
        self.plusIcon = plusIcon
    }

    private var isMenuOpen: Bool {
        presentation.isPresented(id: menuId)
    }

    public var body: some View {
        Button {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                presentation.toggle(id: menuId)
            }
        } label: {
            if let altIcon = alternateIcon, !isMenuOpen {
                altIcon
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.white.opacity(0.7))
            } else {
                plusIcon
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .rotationEffect(.degrees(isMenuOpen ? 45 : 0))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .frame(width: size, height: size)
        .contentShape(Circle())
        .background(backgroundColor, in: Circle())
        .buttonStyle(BounceButtonStyle())
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isMenuOpen)
    }
}
