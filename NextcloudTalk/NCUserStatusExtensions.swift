//
// SPDX-FileCopyrightText: 2024 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: GPL-3.0-or-later
//

import Foundation
import SwiftUI

extension NCUserStatus {

    static func getOnlineIcon() -> some View {
        return Image(systemName: "circle.fill").font(.system(size: 16)).symbolRenderingMode(.monochrome).foregroundStyle(.green)
    }

    static func getAwayIcon() -> some View {
        return Image(systemName: "moon.fill").font(.system(size: 16)).symbolRenderingMode(.monochrome).foregroundStyle(.yellow)
    }

    static func getDoNotDisturbIcon() -> some View {
        if #available(iOS 16.1, *) {
            return Image(systemName: "wrongwaysign.fill").font(.system(size: 16)).symbolRenderingMode(.palette).foregroundStyle(.white, .red)
        }

        return Image(systemName: "minus.circle.fill").font(.system(size: 16)).symbolRenderingMode(.palette).foregroundStyle(.white, .red)
    }

    static func getInvisibleIcon() -> some View {
        return Image(systemName: "circle").font(.system(size: 16, weight: .black)).foregroundColor(.primary)
    }

    static func getUserStatusIcon(userStatus: String) -> any View {
        if userStatus == kUserStatusOnline {
            return getOnlineIcon()
        } else if userStatus == kUserStatusAway {
            return getAwayIcon()
        } else if userStatus == kUserStatusDND {
            return getDoNotDisturbIcon()
        } else if userStatus == kUserStatusInvisible {
            return getInvisibleIcon()
        }

        return Image(systemName: "person.fill.questionmark")
    }
}
