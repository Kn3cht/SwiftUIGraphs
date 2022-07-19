//
// Created by Gerald Mahlknecht on 19.07.22.
//

import SwiftUI

/// DYLineChartView
public struct DYMultiLineChartView: View, DYGroupedGridChart {

    public var dataPoints: [DYGroupedDataPoint]

    public var settings: DYMultiLineChartSettings
    
    public init(
        dataPoints: [DYGroupedDataPoint],
        settings: DYMultiLineChartSettings
    ) {
        self.dataPoints = dataPoints
        self.settings = settings
    }

    public var body: some View {
        Text("TODO")
    }
}
