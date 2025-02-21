//
//  DYFractionChartHeaderView.swift
//  
//
//  Created by Dominik Butz on 25/3/2021.
//

import SwiftUI

/// DYFractionChartInfoView. a view that displays details of the selected DYChartFraction. 
public struct DYFractionChartInfoView: View {
    
    let title: String
    let data: [DYChartFraction]
    @Binding var selectedId: String?
    let valueConverter: (Double)->String
    
    /// DYFractionChartInfoView initializer
    /// - Parameters:
    ///   - title: a title.
    ///   - data: an array of DYChartFractions
    ///   - selectedId: the id of the selected DYChartFraction
    ///   - valueConverter: implement a logic to convert the double value to a string.
    public init(title: String, data: [DYChartFraction], selectedId: Binding<String?>, valueConverter: @escaping (Double)->String) {
        self.title = title
        self.data = data
        self._selectedId = selectedId
        self.valueConverter = valueConverter
        
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if self.title != "" {
                Text(self.title).font(.headline).bold()
            }
            if let selectedId = selectedId, let fraction = self.fractionFor(id: selectedId) {
                Text(fraction.title).font(.headline)
                Text(self.valueConverter(fraction.value) + " - " + fraction.value.percentageString(totalValue: data.reduce(0) { $0 + $1.value}) )
            }
        }
    }
    
    func fractionFor(id: String)->DYChartFraction? {
        return self.data.filter({$0.id == id}).first
    }
}

struct DYFractionChartHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        let data = DYChartFraction.exampleData()
        return DYFractionChartInfoView(title: "Example data", data: data, selectedId: .constant(data.first!.id), valueConverter: { value in
            value.toCurrencyString()
        })
    }
}
