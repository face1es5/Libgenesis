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
                .frame(height: 30)
                .toggleStyle(.checkmark)
            }
        } label: {
            HStack {
                Text("Format")
                Image(systemName: "doc.fill")
            }
            .onTapGesture {
                withAnimation {
                    expand.toggle()
                }
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

struct ColumnFilterView: View {
    @Binding var columnFilter: ColumnFilter
    @State var iscolExpanded: Bool = true
    var body: some View {
        DisclosureGroup(isExpanded: $iscolExpanded) {
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
        } label: {
            HStack {
                Text("Column")
                Image(systemName: "rectangle.split.3x1.fill")
            }
            .onTapGesture {
                withAnimation {
                    iscolExpanded.toggle()
                }
            }
            .help("Once any column choosed except Default, search string will be applied into that field only.")
        }
    }

}

struct FilterContextView: View {
    @Binding var columnFilter: ColumnFilter
    @Binding var formatFilters: Set<FormatFilter>
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Reset") {
                    clearFilter()
                }
            }
            Form {
                PageNumPicker()
                HStack(alignment: .top, spacing: 10) {
                    ColumnFilterView(columnFilter: $columnFilter)
                    AdvanceFilterView(formatFilters: $formatFilters)
                }
            }
            
        }
        .padding()
        .frame(width: 300)

    }
    
    private func clearFilter() {
        columnFilter = .def
        formatFilters = [.all]
    }

}
