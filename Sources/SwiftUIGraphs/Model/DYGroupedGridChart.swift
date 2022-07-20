//
// Created by Gerald Mahlknecht on 19.07.22.
//

import SwiftUI

protocol DYGroupedGridChart: View {

    var dataPoints: [DYGroupedDataPoint] { get set }
    var settings: DYMultiLineChartSettings { get set }
    var yAxisScalers: [YAxisScaler] {get set}

    var yValueConverter: (Double)->String {get set}
    var xValueConverter: (Double)->String {get set}
}

extension DYGroupedGridChart {
    func yAxisView(geo: GeometryProxy, yAxisSettings: YAxisSettings, yAxisScaler: YAxisScaler)-> some View {
        VStack(alignment: .trailing, spacing: 0) {
            let interval = yAxisScaler.tickSpacing ?? yAxisSettings.yAxisIntervalOverride ?? 0
            if let maxValue = self.yAxisValues(yAxisSettings: yAxisSettings, yAxisScaler: yAxisScaler).first, maxValue >=  interval {
                Text(self.yValueConverter(maxValue)).font(.system(size: yAxisSettings.yAxisFontSize))
            }
            ForEach(self.yAxisValues(yAxisSettings: yAxisSettings, yAxisScaler: yAxisScaler), id: \.self) {value in
                if value != self.yAxisMinMax(yAxisSettings: yAxisSettings, yAxisScaler: yAxisScaler).max {
                    Spacer(minLength: 0)
                    Text(self.yValueConverter(value)).font(.system(size: yAxisSettings.yAxisFontSize))
                }

            }

            if self.yAxisValues(yAxisSettings: yAxisSettings, yAxisScaler: yAxisScaler).count == 1 {
                Spacer()
            }
        }
    }

    func yAxisValues(yAxisSettings: YAxisSettings, yAxisScaler: YAxisScaler)->[Double] {

        guard let interval = yAxisSettings.yAxisIntervalOverride else {
            return yAxisScaler.scaledValues().reversed()
        }
        var values:[Double] = []
        let count = yAxisValueCount(yAxisSettings: yAxisSettings, yAxisScaler: yAxisScaler)
        let yAxisInterval = interval
        var currentValue  = yAxisMinMax(yAxisSettings: yAxisSettings, yAxisScaler: yAxisScaler).max

        for _ in 0..<(count) {
            values.append(currentValue)
            currentValue -= yAxisInterval
        }
        return values
    }

    func yAxisValueCount(yAxisSettings: YAxisSettings, yAxisScaler: YAxisScaler)->Int {
        //   print("y axis lines \(self.yAxisScaler.scaledValues().count)")
        guard let interval = yAxisSettings.yAxisIntervalOverride else {
            return yAxisScaler.scaledValues().count
        }
        let yAxisMinMax = self.yAxisMinMax(yAxisSettings: yAxisSettings, yAxisScaler: yAxisScaler)
        let yAxisInterval = interval
        let count = (yAxisMinMax.max - yAxisMinMax.min) / yAxisInterval
        //   print("line count \(count + 1)")
        return Int(count) + 1
    }



    func yAxisMinMax(yAxisSettings: YAxisSettings, yAxisScaler: YAxisScaler)->( min: Double, max: Double){

        let scaledMin = yAxisSettings.yAxisMinMaxOverride?.min ?? yAxisScaler.scaledMin ?? 0
        let scaledMax = yAxisSettings.yAxisMinMaxOverride?.max ?? yAxisScaler.scaledMax ?? 1

        return (min: scaledMin, max: scaledMax)
    }
}
