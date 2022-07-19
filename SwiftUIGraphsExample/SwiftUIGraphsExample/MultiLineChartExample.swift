//
// Created by Gerald Mahlknecht on 19.07.22.
//

import SwiftUI
import SwiftUIGraphs

struct MultiLineChartExample: View {
    @State private var selectedDataIndex: Int = 0

    var body: some View {
        let groupedExampleData = DYDataPoint.groupedExampleData

        return  GeometryReader { proxy in
            VStack {
                DYGridChartHeaderView(title: "Text", dataPoints: groupedExampleData, selectedIndex: self.$selectedDataIndex, isLandscape: proxy.size.height < proxy.size.width, xValueConverter: { (xValue) -> String in
                    return Date(timeIntervalSinceReferenceDate: xValue).toString(format:"dd-MM-yyyy HH:mm")
                }, yValueConverter: { (yValue) -> String in
                    return  yValue.toDecimalString(maxFractionDigits: 1) + " KG"

                })

                DYMultiLineChartView(dataPoints: groupedExampleData, selectedIndex: $selectedDataIndex, xValueConverter: { (xValue) -> String in
                    // this is for the x-Axis values - date should be short
                    return Date(timeIntervalSinceReferenceDate: xValue).toString(format:"dd-MM")
                }, yValueConverter: { (yValue) -> String in
                    return  yValue.toDecimalString(maxFractionDigits: 0)
                    //  return TimeInterval(yValue).toString() ?? ""
                }, chartFrameHeight: proxy.size.height > proxy.size.width ? proxy.size.height * 0.4 : proxy.size.height * 0.65,  settings: DYLineChartSettings(showPointMarkers: true, lateralPadding: (0, 0), yAxisSettings: YAxisSettings(yAxisFontSize:fontSize), xAxisSettings: DYLineChartXAxisSettings(showXAxis: true, xAxisInterval: 604800, xAxisFontSize: fontSize)))  // 604800 seconds per week
//yAxisSettings: YAxisSettings(showYAxis: true, yAxisPosition: .leading, yAxisMinMaxOverride: (min: 0, max: Double(Int(exampleData.map({$0.yValue}).max() ?? 0).nearest(multipleOf: 1800, up: true))), yAxisIntervalOverride: 1800)
                Spacer()
            }.padding()
        }.navigationTitle("Weight Lifting Volume")
    }

    var fontSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .phone ? 8 : 10
    }
}

struct MultiLineChartExample_Previews: PreviewProvider {
    static var previews: some View {
        MultiLineChartExample()
    }
}

