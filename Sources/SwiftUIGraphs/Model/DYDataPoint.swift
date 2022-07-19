//
//  DYDataPoint.swift
//  SwiftUIGraphsExample
//
//  Created by Dominik Butz on 2/2/2021.
//

import Foundation

public struct DYDataPoint: Identifiable {
    
    public let id:UUID = UUID()
    
    /// DYDataPoint initializer
    /// - Parameters:
    ///   - xValue: the x-value of the data point.
    ///   - yValue: the y-value of the data point.
    public init(xValue: Double, yValue: Double, group: String? = nil) {
        self.xValue = xValue
        self.yValue = yValue
        self.group = group
    }
    
    public var xValue: Double
    public var yValue: Double
    public var group: String?

    /// example data: e.g. y-values are seconds.
    public static var exampleData0: [DYDataPoint] {
        var dataPoints:[DYDataPoint] = []
        
        var endDate = Date().add(units: -3, component: .hour)
        
        for _ in 0..<50 {
            let yValue = Int.random(in: 6000 ..< 12000)
            let xValue =  endDate.timeIntervalSinceReferenceDate
            let dataPoint = DYDataPoint(xValue: xValue, yValue: Double(yValue))
            dataPoints.append(dataPoint)
            let randomDayDifference = Int.random(in: 1 ..< 8)
            endDate = endDate.add(units: -randomDayDifference, component: .day)
        }

        return dataPoints
    }
    
    /// e.g. weight volume per exercise
    public static var exampleData1: [DYDataPoint] {
        var dataPoints:[DYDataPoint] = []
        
        var endDate = Date().add(units: -3, component: .hour)
        
        for _ in 0..<14 {
            let yValue = Double.random(in: 1500 ..< 1940)
            let xValue =  endDate.timeIntervalSinceReferenceDate
            let dataPoint = DYDataPoint(xValue: xValue, yValue: yValue)
            dataPoints.append(dataPoint)
            let randomDayDifference = Int.random(in: 1 ..< 8)
            endDate = endDate.add(units: -randomDayDifference, component: .day)
        }

        return dataPoints
    }
    
    /// example data: e.g. y-values are seconds. It also contains random colours for each data point.
    public static var exampleData2: [DYDataPoint] {
        var dataPoints:[DYDataPoint] = []
        
        var endDate = Date().add(units: -3, component: .hour)
        
        for _ in 0..<20 {
          let yValue = Int.random(in: 6000 ..< 12000)

            let xValue =  endDate.timeIntervalSinceReferenceDate
            let dataPoint = DYDataPoint(xValue: xValue, yValue: Double(yValue))
            dataPoints.append(dataPoint)
            let randomDayDifference = Int.random(in: 1 ..< 8)
            endDate = endDate.add(units: -randomDayDifference, component: .day)
        }

        return dataPoints
    }

    public static var groupedExampleData: [DYDataPoint] {
        let groupedData0 = exampleData0
        let groupedData1 = exampleData1

        var exampleData: [DYDataPoint] = []
        groupedData0.forEach({ dp in
            let dataPoint = DYDataPoint(xValue: dp.xValue, yValue: Double(dp.yValue), group: "group0")

            exampleData.append(dataPoint)
        })
        groupedData1.forEach({ dp in
            let dataPoint = DYDataPoint(xValue: dp.xValue, yValue: Double(dp.yValue), group: "group1")

            exampleData.append(dataPoint)
        })

        return exampleData
    }
}
