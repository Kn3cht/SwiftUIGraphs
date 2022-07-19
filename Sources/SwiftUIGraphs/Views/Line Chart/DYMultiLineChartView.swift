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

    var minX: Double
    var maxX: Double

    public internal(set) var yAxisScalers: [YAxisScaler] = []

    var marginSum: CGFloat {
        return settings.lateralPadding.leading + settings.lateralPadding.trailing
    }

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
        let xValues = dataPoints.map({$0.xValue})

        self.minX = xValues.min() ?? 0
        self.maxX = xValues.max() ?? 0
    }

    public var body: some View {
        GeometryReader { geo in
            Group {
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
                            Divider()
                        } else {
                            Text("Scaler not found")
                        }
                    }

                    ScrollView(.horizontal) {
                        VStack {
                            Spacer()

                            xAxisView()
                                    .frame(width: 3000, height: 20)
                        }
                    }.frame(height: geo.size.height)
                }
            }
        }
    }

    private func xAxisGridLines()-> some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Path { p in
                    let totalWidth = geo.size.width - marginSum
                    let totalHeight = geo.size.height
                    var xPosition: CGFloat = settings.lateralPadding.leading
                    let count = xAxisLineCount()
                    let interval:Double = (settings.xAxisSettings as! DYLineChartXAxisSettings).xAxisInterval
                    let xAxisMinMax = xAxisMinMax()
                    let convertedXAxisInterval = totalWidth * CGFloat(interval / (xAxisMinMax.max - xAxisMinMax.min))
                    for _ in 0..<count + 1 {
                        p.move(to: CGPoint(x: xPosition, y: 0))
                        p.addLine(to: CGPoint(x:xPosition, y: totalHeight))
                        xPosition += convertedXAxisInterval
                    }
                }.stroke(style: (settings.xAxisSettings as! DYLineChartXAxisSettings).xAxisLineStrokeStyle)
                        .foregroundColor(.secondary)
            }


        }
    }

    internal func xAxisLineCount()->Int {

        let xAxisMinMax = self.xAxisMinMax()

        let interval = xAxisMinMax.max - xAxisMinMax.min
        let xAxisInterval = (self.settings.xAxisSettings as! DYLineChartXAxisSettings).xAxisInterval
        let count = interval / xAxisInterval
        // let count = 100
        return Int(count)
    }

    internal func xAxisMinMax()->(min: Double, max: Double){
        let xValues = dataPoints.map({$0.xValue})
        return (min: xValues.min() ?? 0, max: xValues.max() ?? 0)
    }


    func xAxisLabelStrings()->[String] {
        return self.dataPoints.map({self.xValueConverter($0.xValue)})
    }

    func xAxisLabelSteps(totalWidth: CGFloat)->Int {
        let allLabels = xAxisLabelStrings()

        let fontSize =  settings.xAxisSettings.xAxisFontSize

        let ctFont = CTFontCreateWithName(("SFProText-Regular" as CFString), fontSize, nil)
        // let x be the padding
        var count = 1
        var totalWidthAllLabels: CGFloat = allLabels.map({$0.width(ctFont: ctFont)}).reduce(0, +)
        if totalWidthAllLabels < totalWidth {
            return count
        }

        var labels: [String] = allLabels
        while totalWidthAllLabels  > totalWidth {
            count += 1
            labels = labels.indices.compactMap({
                if $0 % count != 0 { return labels[$0] }
                else { return nil }
            })
            totalWidthAllLabels = labels.map({$0.width(ctFont: ctFont)}).reduce(0, +)
        }

        return count

    }

    internal func xAxisValues()->[Double] {
        var values:[Double] = []
        let count = self.xAxisLineCount()
        var currentValue = self.xAxisMinMax().min
        for _ in 0..<(count + 1) {
            values.append(currentValue)
            currentValue += (settings.xAxisSettings as! DYLineChartXAxisSettings).xAxisInterval

        }
        return values
    }

    private func xAxisView()-> some View {

        ZStack(alignment: .center) {
            GeometryReader { geo in
                let labelSteps = self.xAxisLabelSteps(totalWidth: geo.size.width - marginSum)
                ForEach(self.xAxisValues(), id:\.self) { value in
                    let i = self.xAxisValues().firstIndex(of: value) ?? 0
                    if  i % labelSteps == 0 {
                        self.xAxisIntervalLabelViewFor(value: value, totalWidth: geo.size.width - marginSum)
                    }
                }
            }
        }
    }

    private func xAxisIntervalLabelViewFor(value:Double, totalWidth: CGFloat)-> some View {
        Text(self.xValueConverter(value))
                .font(.system(size: settings.xAxisSettings.xAxisFontSize))
                .position(x: self.convertToXCoordinate(value: value, width: totalWidth), y: 10)
    }

    private func convertToXCoordinate(value: Double, width: CGFloat) -> CGFloat {

        let normalizationFactor = normalizationFactor(value: value, maxValue: maxX, minValue: minX)
        let xCoordinate = width * CGFloat(normalizationFactor)

        return xCoordinate

    }

    func normalizationFactor(value: Double, maxValue: Double, minValue: Double) -> Double {
        (value - minValue) / (maxValue - minValue)
    }
}
