//
// Created by Gerald Mahlknecht on 19.07.22.
//

import SwiftUI
import SwiftUIGraphs

struct MultiLineChartExample: View {
    @State private var selectedDataIndex: Int = 0

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
                                        axisIdentifier: "axis0"
                                ),
                                YAxisSettings(
                                        axisIdentifier: "axis1"
                                )
                            ],
                            groupSettings: [
                                DYGroupSettings(
                                    id: "group0",
                                    color: .blue,
                                        axisId: "axis0"
                                ),
                                DYGroupSettings(
                                    id: "group1",
                                    color: .blue,
                                        axisId: "axis1"
                                ),
                            ]
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

