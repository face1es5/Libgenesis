//
//  FilterView.swift
//  Libgenesis
//
//  Created by Fish on 8/9/2024.
//

import SwiftUI

struct AdvanceFilterView: View {
    @Binding var formatFilters: Set<FormatFilter>
    var body: some View {
        DisclosureGroup {
            Form {
                ForEach(FormatFilter.allCases) { filter in
                    Toggle(filter.desc, isOn: Binding(
                        get: { formatFilters.contains(filter) },
                        set: {
                            if $0 {
                                formatFilters.insert(filter)
                            } else {
                                formatFilters.remove(filter)
                            }
                        }
                    ))
                    .frame(height: 20)
                    .toggleStyle(.checkmark)
                }
            }
            .padding(.top, 5)
        } label: {
            HStack {
                Text("Format filters")
                Image(systemName: "hammer")
                    .foregroundColor(.blue)
            }
            .help("Choose expected formats")
        }
    }
}

struct FilterContextView: View {
    @Binding var formatFilters: Set<FormatFilter>
    @Binding var columnFilter: ColumnFilter
    @AppStorage("perPageN") var perPageN: Int = 25
    
    var body: some View {
        Form {
            Button("Clear filters") {
                clearFilter()
            }
            ForEach(ColumnFilter.allCases) { filter in
                Toggle(filter.desc, isOn: Binding(
                    get: { columnFilter == filter },
                    set: {
                        if $0 {
                            columnFilter = filter
                        } else {
                            columnFilter = .def
                        }
                    }
                ))
                .frame(height: 30)
                .toggleStyle(.checkmark)
            }
            AdvanceFilterView(formatFilters: $formatFilters)
            Picker("", selection: $perPageN) {
                Text("25").tag(25)
                Text("50").tag(50)
                Text("100").tag(100)
            }
            .help("Switch results num of per searching.")
            .pickerStyle(.segmented)
            .padding(.top, 5)
        }
        .padding()
    }
    
    private func clearFilter() {
        columnFilter = .def
        formatFilters = [.def]
    }

}
