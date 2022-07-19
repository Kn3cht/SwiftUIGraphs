//
// Created by Gerald Mahlknecht on 19.07.22.
//

import Foundation
import SwiftUI

public struct DYGroupSettings: Identifiable {
    public var id: String

    var color: Color
    var axisId: String

    public init(
            id: String,
            color: Color = .orange,
            axisId: String
    ) {
        self.id = id
        self.color = color
        self.axisId = axisId
    }
}