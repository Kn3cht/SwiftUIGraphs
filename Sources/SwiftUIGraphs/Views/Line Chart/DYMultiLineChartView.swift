//
// Created by Gerald Mahlknecht on 19.07.22.
//

import SwiftUI

/// DYLineChartView
public struct DYMultiLineChartView: View, DYGroupedGridChart {

    public var dataPoints: [DYGroupedDataPoint]

    public var settings: DYMultiLineChartSettings

    var yValueConverter: (Double) -> String

    var xValueConverter: (Double) -> String

    public internal(set) var yAxisScalers: [YAxisScaler] = []

    public init(
            dataPoints: [DYGroupedDataPoint],
            settings: DYMultiLineChartSettings,
            yValueConverter: @escaping (Double) -> String = { value in "\(value)"},
            xValueConverter: @escaping (Double) -> String = { value in "\(value)"}
    ) {
        self.dataPoints = dataPoints
        self.settings = settings
        self.yValueConverter = yValueConverter
        self.xValueConverter = xValueConverter

        // TODO for each group
        var yAxisScalers: [YAxisScaler] = []
        for groupSettings in settings.groupSettings {
            let axisId = groupSettings.axisId

            let filteredDataPoints = dataPoints.filter { dp in
                dp.groupId == groupSettings.id
            }

            let yAxisSettings = settings.yAxesSettings.first(where: { aS in
                aS.axisIdentifier == axisId
            })!

            var min =  filteredDataPoints.map({$0.yValue}).min() ?? 0
            if let overrideMin = yAxisSettings.yAxisMinMaxOverride?.min, overrideMin < min {
                min = overrideMin
            }
            var max = filteredDataPoints.map({$0.yValue}).max() ?? 0
            if let overrideMax = yAxisSettings.yAxisMinMaxOverride?.max, overrideMax > max {
                max = overrideMax
            }

            yAxisScalers.append(YAxisScaler(axisId: axisId, min: min, max: max, maxTicks: 10))
        }

        self.yAxisScalers = yAxisScalers
    }

    public var body: some View {
        GeometryReader { geo in
            Group {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(settings.yAxesSettings, id: \.axisIdentifier) { yAxisSettings in
                            let yAxisScaler = yAxisScalers.first(where: { yAxisScaler in
                                yAxisScaler.axisId == yAxisSettings.axisIdentifier
                            })

                            if let axisScaler = yAxisScaler {
                                self.yAxisView(
                                                geo: geo,
                                                yAxisSettings: yAxisSettings,
                                                yAxisScaler: axisScaler
                                        )
                                        .padding(.trailing, 5)
                                        .frame(width: yAxisSettings.yAxisViewWidth)
                            } else {
                                Text("Scaler not found")
                            }

                        }
                    }

                }
            }
        }
    }



}
