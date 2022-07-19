//
// Created by Gerald Mahlknecht on 19.07.22.
//

import Foundation
import SwiftUI

public protocol DYGroupedGridChart: View {

    var dataPoints: [DYGroupedDataPoint] {get set}
    // public var settings: DYMultiLineChartSettings { get set }
}
