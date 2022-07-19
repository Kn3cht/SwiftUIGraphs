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
                        Date(timeIntervalSinceReferenceDate: xValue).toString(format:"dd-MM-yyyy HH:mm")
                }, yValueConverter: { (yValue) -> String in
                        yValue.toDecimalString(maxFractionDigits: 1) + " KG"

                })

                DYMultiLineChartView(
                        dataPoints: groupedExampleData,
                        selectedIndex: $selectedDataIndex,
                        xValueConverter: { (xValue) -> String in // this is for the x-Axis values - date should be short
                            Date(timeIntervalSinceReferenceDate: xValue).toString(format:"dd-MM")
                },
                        yValueConverter: { (yValue) -> String in
                            yValue.toDecimalString(maxFractionDigits: 0)
                },
                        chartFrameHeight: proxy.size.height > proxy.size.width ? proxy.size.height * 0.4 : proxy.size.height * 0.65,
                        settings: DYLineChartSettings(
                                showPointMarkers: true,
                                lateralPadding: (0, 0),
                                interpolationType: .linear,
                                yAxisSettings: YAxisSettings(yAxisFontSize:fontSize),
                                xAxisSettings: DYLineChartXAxisSettings(
                                        showXAxis: true,
                                        xAxisInterval: 604800,
                                        xAxisFontSize: fontSize),
                                showAnimation: false
                        )
                )  // 604800 seconds per week
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

