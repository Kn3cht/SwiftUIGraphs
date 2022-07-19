//
// Created by Gerald Mahlknecht on 19.07.22.
//

import Foundation

public struct DYGroupedDataPoint: Identifiable {

    public let id:UUID = UUID()

    /// DYDataPoint initializer
    /// - Parameters:
    ///   - xValue: the x-value of the data point.
    ///   - yValue: the y-value of the data point.
    ///   - groupId: used for the mapping to its group settings
    public init(xValue: Double, yValue: Double, groupId: String? = nil) {
        self.xValue = xValue
        self.yValue = yValue
        self.groupId = groupId
    }

    public var xValue: Double
    public var yValue: Double
    public var groupId: String?

    private static var exampleData0: [DYGroupedDataPoint] {
        var dataPoints:[DYGroupedDataPoint] = []

        var endDate = Date().add(units: -3, component: .hour)
        
        for _ in 0..<20 {
            let yValue = Int.random(in: 10 ..< 120)

            let xValue =  endDate.timeIntervalSinceReferenceDate
            let dataPoint = DYGroupedDataPoint(xValue: xValue, yValue: Double(yValue))
            dataPoints.append(dataPoint)
            let randomDayDifference = Int.random(in: 1 ..< 8)
            endDate = endDate.add(units: -randomDayDifference, component: .day)
        }

        return dataPoints
    }

    private static var exampleData1: [DYGroupedDataPoint] {
        var dataPoints:[DYGroupedDataPoint] = []

        var endDate = Date().add(units: -3, component: .hour)

        for _ in 0..<20 {
            let yValue = Int.random(in: 6000 ..< 12000)

            let xValue =  endDate.timeIntervalSinceReferenceDate
            let dataPoint = DYGroupedDataPoint(xValue: xValue, yValue: Double(yValue))
            dataPoints.append(dataPoint)
            let randomDayDifference = Int.random(in: 1 ..< 8)
            endDate = endDate.add(units: -randomDayDifference, component: .day)
        }

        return dataPoints
    }

    public static var groupedExampleData: [DYGroupedDataPoint] {
        let groupedData3 = exampleData0
        let groupedData4 = exampleData1

        var exampleData: [DYGroupedDataPoint] = []
        groupedData3.forEach({ dp in
            let dataPoint = DYGroupedDataPoint(xValue: dp.xValue, yValue: Double(dp.yValue), groupId: "group0")

            exampleData.append(dataPoint)
        })
        groupedData4.forEach({ dp in
            let dataPoint = DYGroupedDataPoint(xValue: dp.xValue, yValue: Double(dp.yValue), groupId: "group1")

            exampleData.append(dataPoint)
        })

        exampleData.sort(by: { (dp1, dp2) in
            dp1.xValue < dp2.xValue
        })

        return exampleData
    }
}
