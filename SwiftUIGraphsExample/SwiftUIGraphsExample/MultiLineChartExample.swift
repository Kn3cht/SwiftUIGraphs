//
// Created by Gerald Mahlknecht on 19.07.22.
//

import SwiftUI
import SwiftUIGraphs

struct MultiLineChartExample: View {

    var body: some View {
        let groupedExampleData = DYGroupedDataPoint.groupedExampleData

        return  GeometryReader { proxy in
            VStack {

                DYMultiLineChartView(
                        dataPoints: groupedExampleData,
                        settings: DYMultiLineChartSettings(
                            showAnimation: false,
                            yAxesSettings: [
                                YAxisSettings(
                                        axisIdentifier: "axis0",
                                        axisName: "Temperature"
                                ),
                                YAxisSettings(
                                        axisIdentifier: "axis1",
                                        axisName: "BloodPressure"
                                )
                            ], xAxisSettings: DYLineChartXAxisSettings(showXAxis: true, xAxisInterval: 604800, xAxisFontSize: fontSize),
                            groupSettings: [
                                DYGroupSettings(
                                    id: "group0",
                                    color: .blue,
                                        axisId: "axis0"
                                ),
                                DYGroupSettings(
                                    id: "group1",
                                    color: .red,
                                        axisId: "axis1"
                                ),
                            ]
                        ),
                        xValueConverter: { value in
                            if #available(iOS 15.0, *) {
                                return Date(timeIntervalSince1970: value).formatted(date: .long, time: .omitted)
                            } else {
                                return "ios15 required"
                            }
                        }
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

