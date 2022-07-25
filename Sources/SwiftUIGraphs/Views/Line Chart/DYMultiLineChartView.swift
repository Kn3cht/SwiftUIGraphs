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

    let indicatorLineWidth = CGFloat(200)

    var epsilonArea: CGFloat {
        indicatorLineWidth / 2
    }

    var groupDataDictionary: [String: [DYGroupedDataPoint]] = [:]

    public internal(set) var yAxisScalers: [YAxisScaler] = []

    @State private var lineOffset: CGFloat = 0 // Vertical line offset
    @State private var lineOffsetOld: CGFloat = 0 // Vertical line offset
    @State private var isSelected: Bool = false // Is the user touching the graph

    @State private var pointsInArea: [DYGroupedDataPoint] = []
    @State private var closesPointsPerGroup: [DYGroupedDataPoint] = []

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

        // Create group dictionary
        for dataPoint in dataPoints {
            if let groupId = dataPoint.groupId {
                let elements = groupDataDictionary[groupId] ?? []
                groupDataDictionary[groupId] = elements + [dataPoint]
            }
        }
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
                            HStack {
                                self.yAxisView(
                                                geo: geo,
                                                yAxisSettings: yAxisSettings,
                                                yAxisScaler: axisScaler
                                        )
                                        .padding(.bottom, 20)
                                        .frame(width: yAxisSettings.yAxisViewWidth, height: geo.size.height - 20)
                            }
                        } else {
                            Text("Scaler not found")
                        }
                    }

                    ScrollView(axes: [.horizontal], showsIndicators: false,
                            offsetChanged: { offset in
                                // self.lineOffset = lineOffsetOld + convertToXCoordinate(value: $0.x, width: geo.size.width)
                                // self.lineOffset = offset.x
                            }) {
                        ScrollViewReader { scrollValue in
                            VStack {
                                Spacer()
                                ZStack {
                                    ForEach(settings.yAxesSettings, id: \.axisIdentifier) { axisSettings in
                                        let yAxisScaler = yAxisScalers.first(where: { yAxisScaler in
                                            yAxisScaler.axisId == axisSettings.axisIdentifier
                                        })

                                        if let axisScaler = yAxisScaler {
                                            yAxisGridLines(yAxisSettings: axisSettings, yAxisScaler: axisScaler)
                                        } else {
                                            Text("Scaler not found")
                                        }

                                    }
                                    xAxisGridLines()

                                    addUserInteraction()

                                    lines()
                                    points()

                                }

                                xAxisView()
                                        .padding(.horizontal)
                                        .frame(width: 3000, height: 20)
                            }
                                .padding(.leading, 50)
                                .padding(.trailing)
                    }
                    }
                            // .offset(x: axisWidthSum)
                            .frame(height: geo.size.height)
                }
            }
        }
    }

    private func points()->some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            Group {
                let keys = groupDataDictionary.map{$0.key}
                ForEach(keys.indices) { index in
                    let groupId = keys[index]
                    let group = self.settings.groupSettings.first(where: { group in
                        group.id == groupId
                    })!
                    let axisId = group.axisId
                    let yAxisScaler = yAxisScalers.first(where: { scaler in
                        scaler.axisId == axisId
                    })!

                    let yAxisSettings = self.settings.yAxesSettings.first(where: { axisSettings in
                        axisSettings.axisIdentifier == axisId
                    })!

                    let values = groupDataDictionary[groupId] ?? []

                    ForEach(values) { dataPoint in
                        let xCoordinate = settings.lateralPadding.leading + self.convertToXCoordinate(value: dataPoint.xValue, width: width) - 5
                        let yCoordinate = (height - self.convertToYCoordinate(yAxisSettings: yAxisSettings, yAxisScaler: yAxisScaler, value: dataPoint.yValue, height: height)) - 5
                        ZStack {
                            if self.closesPointsPerGroup.contains(where: { pIA in
                                pIA.id == dataPoint.id
                            }) {
                                Circle()
                                        .frame(width: 25, height: 25, alignment: .center)
                                        .foregroundColor(Color.black.opacity(0.2))
                                        .background(Color.black.opacity(0.2))
                                        .cornerRadius(12.5)
                                        .offset(x: xCoordinate, y: yCoordinate)
                            }

                            Circle()
                                    .frame(width: 15, height: 15, alignment: .center)
                                    .foregroundColor(group.color)
                                    .background(group.color)
                                    .cornerRadius(7.5)
                                    .offset(x: xCoordinate, y: yCoordinate)
                                    .onTapGesture {
                                        // self.lineOffset = xCoordinate
                                        // self.lineOffsetOld = lineOffset
                                        dragOnChanged(value: xCoordinate, width: geo.size.width)
                                    }
                        }
                    }
                }
            }
        }
    }

    private func lines() -> some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let keys = groupDataDictionary.map{$0.key}

            ForEach(keys.indices) { index in
                let groupId = keys[index]
                let group = self.settings.groupSettings.first(where: { group in
                    group.id == groupId
                })!
                let axisId = group.axisId
                let yAxisScaler = yAxisScalers.first(where: { scaler in
                    scaler.axisId == axisId
                })!

                let yAxisSettings = self.settings.yAxesSettings.first(where: { axisSettings in
                    axisSettings.axisIdentifier == axisId
                })!

                let values = (groupDataDictionary[groupId] ?? []).sorted(by: { (dp1, dp2) in
                    dp1.xValue < dp2.xValue
                })

                pathFor(yAxisSettings: yAxisSettings, yAxisScaler: yAxisScaler, dataPoints: values, width: width, height: height)
                        .stroke(group.color, style: StrokeStyle(lineWidth: 1))
            }

        }
    }

    func convertToYCoordinate(yAxisSettings: YAxisSettings, yAxisScaler: YAxisScaler, value:Double, height: CGFloat)->CGFloat {

        let yAxisMinMax = self.yAxisMinMax(yAxisSettings: yAxisSettings, yAxisScaler: yAxisScaler)

        let normalizationFactor = normalizationFactor(value: value, maxValue: yAxisMinMax.max, minValue: yAxisMinMax.min)
        let yCoordinate = height * CGFloat(normalizationFactor)

        return yCoordinate
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

    func yAxisGridLines(yAxisSettings: YAxisSettings, yAxisScaler: YAxisScaler) -> some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                let width = geo.size.width
                Path { p in

                    var yPosition:CGFloat = 0

                    let count = self.yAxisValueCount(yAxisSettings: yAxisSettings, yAxisScaler: yAxisScaler)
                    let yAxisInterval = yAxisSettings.yAxisIntervalOverride ?? yAxisScaler.tickSpacing ?? 1

                    let min = self.yAxisMinMax(yAxisSettings: yAxisSettings, yAxisScaler: yAxisScaler).min
                    let max = self.yAxisMinMax(yAxisSettings: yAxisSettings, yAxisScaler: yAxisScaler).max
                    let convertedYAxisInterval  = geo.size.height * CGFloat(yAxisInterval / (max - min))

                    for _ in 0..<count    {

                        p.move(to: CGPoint(x: 0, y: yPosition))
                        p.addLine(to: CGPoint(x: width, y: yPosition))
                        p.closeSubpath()
                        yPosition += convertedYAxisInterval
                    }


                }.stroke(style: yAxisSettings.yAxisGridLinesStrokeStyle)
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

    private func connectPointsWith(yAxisSettings: YAxisSettings, yAxisScaler: YAxisScaler, dataPoints: [DYGroupedDataPoint], path: inout Path, index: Int, point0: CGPoint, height: CGFloat, width: CGFloat)->CGPoint {

        let mappedYValue = convertToYCoordinate(yAxisSettings: yAxisSettings, yAxisScaler: yAxisScaler, value: dataPoints[index].yValue, height: height)
        let mappedXValue = convertToXCoordinate(value: dataPoints[index].xValue, width: width)
        let point1 = CGPoint(x: settings.lateralPadding.leading + mappedXValue, y: height - mappedYValue)

        path.addLine(to: point1)
        return point1
    }

    func pathFor(yAxisSettings: YAxisSettings, yAxisScaler: YAxisScaler, dataPoints: [DYGroupedDataPoint], width: CGFloat, height: CGFloat)->Path {
        Path { path in
            path  = drawCompletePathWith(yAxisSettings: yAxisSettings, yAxisScaler: yAxisScaler, dataPoints: dataPoints, path: &path, height: height, width: width)
        }
    }

    func drawCompletePathWith(yAxisSettings: YAxisSettings, yAxisScaler: YAxisScaler, dataPoints: [DYGroupedDataPoint], path: inout Path, height: CGFloat, width: CGFloat)->Path {

        guard let firstYValue = dataPoints.first?.yValue else {return path}

        let xCoordinate = convertToXCoordinate(value: dataPoints.first!.xValue, width: width)
        var point0 = CGPoint(x: xCoordinate, y: height - self.convertToYCoordinate(yAxisSettings: yAxisSettings, yAxisScaler: yAxisScaler, value: firstYValue, height: height))
        path.move(to: point0)
        var index:Int = 0

        for _ in dataPoints {
            if index != 0 {
                point0 = self.connectPointsWith(yAxisSettings: yAxisSettings, yAxisScaler: yAxisScaler, dataPoints: dataPoints, path: &path, index: index, point0: point0, height: height, width: width)
            }
            index += 1

        }

        return path
    }

    private func addUserInteraction() -> some View {
        GeometryReader { geo in

            let height = geo.size.height

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(1))
                        .shadow(color: .black, radius: 5)
                        .overlay(RoundedRectangle(cornerRadius: 25).stroke(lineWidth: 1).foregroundColor(.white).padding(.vertical))


                HStack {
                    Spacer()
                    VStack {
                        ForEach(settings.yAxesSettings, id: \.axisIdentifier) { axisSetting in
                            VStack {
                                Text(axisSetting.axisName!)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                let groupId = settings.groupSettings.first(where: { groupSettings in
                                            groupSettings.axisId == axisSetting.axisIdentifier
                                        })!
                                        .id

                                if let dataPointForGroup = closesPointsPerGroup.first(where: { dp in
                                    dp.groupId == groupId
                                }) {
                                    Text("\(dataPointForGroup.yValue)")
                                            .font(.title2)
                                            .bold()
                                } else {
                                    Text("--")
                                            .font(.title2)
                                            .bold()
                                }
                            }.padding(.bottom)
                        }
                        Spacer()

                    }
                    Spacer()
                }.padding()

            }
                    .frame(width: indicatorLineWidth, height: height)
                    .offset(x: lineOffset - epsilonArea)
                    .gesture(
                            DragGesture(minimumDistance: 0)
                                    .onChanged { dragValue in
                                        dragOnChanged(value: dragValue.translation.width, width: geo.size.width)
                                    }
                                    .onEnded { dragValue in
                                        dragOnEnded(value: dragValue, geo: geo)
                                    }
                    )
                    .onAppear {
                        self.lineOffset = self.settings.lateralPadding.leading
                    }
        }
    }

    private func dragOnChanged(value: CGFloat, width: CGFloat) {
        self.isSelected = true
        self.lineOffset = lineOffsetOld + value
        self.pointsInArea = findPointsInArea(xPosition: lineOffset, width: width)

        var groupedPointsInArea: [String: [DYGroupedDataPoint]] = [:]
        for pointInArea in pointsInArea {
            var groupedPoints = groupedPointsInArea[pointInArea.groupId!] ?? []
            groupedPoints.append(pointInArea)
            groupedPointsInArea[pointInArea.groupId!] = groupedPoints
        }

        var closesPoints: [DYGroupedDataPoint] = []
        for key in groupedPointsInArea.keys {
            let groupedPoints = groupedPointsInArea[key] ?? []
            // print("grouped points", groupedPoints.count)
            if let closesPointPerGroup = findClosestPointTo(xPosition: lineOffset, width: width, dataPoints: groupedPoints) {
                closesPoints.append(closesPointPerGroup)
            }
        }
        self.closesPointsPerGroup = closesPoints
    }

    private func findClosestPointTo(xPosition: CGFloat, width: CGFloat, dataPoints: [DYGroupedDataPoint]) -> DYGroupedDataPoint? {
        dataPoints.compactMap { dp in
                    (dataPoint: dp, diff: abs(convertToXCoordinate(value: dp.xValue, width: width) - xPosition))
        }.min(by: { dp1, dp2 in
                    dp1.diff < dp2.diff
        })?.dataPoint
    }

    private func dragOnEnded(value: DragGesture.Value, geo: GeometryProxy) {
        self.isSelected = false
        self.lineOffsetOld = lineOffsetOld + value.translation.width
    }

    private func scrollOnEnded(value: DragGesture.Value, geo: GeometryProxy) {
        self.isSelected = false
        self.lineOffset = lineOffsetOld + value.translation.width
        self.lineOffsetOld = lineOffsetOld + value.translation.width
    }

    private func findPointsInArea(xPosition: CGFloat, width: CGFloat) -> [DYGroupedDataPoint] {
        dataPoints.filter { dp in
            let xCoordinate = convertToXCoordinate(value: dp.xValue, width: width)

            let lowerBound = xPosition - epsilonArea
            let upperBound = xPosition + epsilonArea

            return xCoordinate > lowerBound && xCoordinate < upperBound
        }
    }
}
