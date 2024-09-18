//
//  FilterView.swift
//  Libgenesis
//
//  Created by Fish on 8/9/2024.
//

import SwiftUI

struct AdvanceFilterView: View {
    @Binding var formatFilters: Set<FormatFilter>
    @State var expand: Bool = true
    var body: some View {
        DisclosureGroup(isExpanded: $expand) {
            Form {
                ForEach(FormatFilter.allCases) { filter in
                    Toggle(filter.desc, isOn: Binding(
                        get: { formatFilters.contains(filter) },
                        set: {
                            if $0 {
                                formatFilters.insert(filter)
                                formatFilters.remove(.all)
                            } else {
                                formatFilters.remove(filter)
                                if formatFilters.count == 0 {
                                    formatFilters.insert(.all)
                                }
                            }
                        }
                    ))
                    .frame(height: 25)
                    .toggleStyle(.checkmark)
                }
            }
            .padding(.top, 5)
        } label: {
            HStack {
                Text("Format")
                Image(systemName: "doc.text")
                    .foregroundColor(.blue)
            }
            .help("Choose expected formats")
        }
    }
}

struct PageNumPicker: View {
    @AppStorage("perPageN") var perPageN: Int = 25
    var body: some View {
        Picker("", selection: $perPageN) {
            Text("25").tag(25)
            Text("50").tag(50)
            Text("100").tag(100)
        }
        .help("Switch results num of per searching.")
        .pickerStyle(.segmented)
        .padding(.top, 5)
    }
}

struct FilterContextView: View {
    @Binding var columnFilter: ColumnFilter
    @Binding var formatFilters: Set<FormatFilter>
    @State var expand: Bool = true

    private var ColumnFilterView: some View {
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
    }
    
    var body: some View {
        Form {
            Button("Clear filters") {
                clearFilter()
            }
            PageNumPicker()
            HStack(alignment: .top, spacing: 10) {
                DisclosureGroup(isExpanded: $expand) {
                    ColumnFilterView
                } label: {
                    HStack {
                        Text("Column")
                        Image(systemName: "eyeglasses")
                            .foregroundColor(.blue)
                    }
                    .help("Once any column choosed except Default, search string will be applied into that field only.")
                }
                AdvanceFilterView(formatFilters: $formatFilters)
            }
            .frame(width: 250)
        }
        .padding()
    }
    
    private func clearFilter() {
        columnFilter = .def
        formatFilters = [.all]
    }

}
