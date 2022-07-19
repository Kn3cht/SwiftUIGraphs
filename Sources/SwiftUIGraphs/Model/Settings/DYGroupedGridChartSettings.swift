//
// Created by Gerald Mahlknecht on 19.07.22.
//

import Foundation
import SwiftUI


/// Grid chart settings (for line chart and bar chart)
public protocol DYGroupedGridChartSettings  {
    // Global settings
    var chartViewBackgroundColor: Color {get set}
    var gradient: LinearGradient {get set}
    var lateralPadding: (leading: CGFloat, trailing: CGFloat) {get set}
    var labelViewDefaultOffset: CGSize {get set}
    var showAnimation: Bool {get set}

    // Multiple yAxes allowed
    var yAxesSettings: [YAxisSettings] {get set }
    var xAxisSettings: XAxisSettings {get set}
    var groupSettings: [DYGroupSettings] {get set}
}

public struct DYMultiLineChartSettings: DYGroupedGridChartSettings {

    // Generic settings
    public var chartViewBackgroundColor: Color
    public var gradient: LinearGradient
    public var lateralPadding: (leading: CGFloat, trailing: CGFloat)
    public var labelViewDefaultOffset: CGSize
    public var showAnimation: Bool

    public var yAxesSettings: [YAxisSettings]

    public var xAxisSettings: XAxisSettings

    public var groupSettings: [DYGroupSettings]

    public init(
        chartViewBackgroundColor: Color = Color(.systemBackground),
        gradient: LinearGradient = LinearGradient(gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]), startPoint: .top, endPoint: .bottom),
        lateralPadding: (leading: CGFloat, trailing: CGFloat) = (0, 0),
        labelViewDefaultOffset: CGSize = CGSize(width: 0, height: -12),
        showAnimation: Bool = true,
        yAxesSettings: [YAxisSettings] = [],
        xAxisSettings: DYBarChartXAxisSettings = DYBarChartXAxisSettings(),
        groupSettings: [DYGroupSettings] = []
    ) {
        self.chartViewBackgroundColor = chartViewBackgroundColor
        self.gradient = gradient
        self.lateralPadding = lateralPadding
        self.labelViewDefaultOffset = labelViewDefaultOffset
        self.showAnimation = showAnimation
        self.yAxesSettings = yAxesSettings
        self.xAxisSettings = xAxisSettings
        self.groupSettings = groupSettings
    }


}