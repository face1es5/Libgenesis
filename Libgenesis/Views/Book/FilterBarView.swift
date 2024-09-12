//
//  FilterBarView.swift
//  Libgenesis
//
//  Created by Fish on 12/9/2024.
//

import SwiftUI

enum MatchMode: String, CaseIterable, Identifiable {
    case contains, word, start, end, re
    var id: Self { self }
    var desc: String {
        switch self {
        case .contains:
            return "Contains"
        case .word:
            return "Matches Word"
        case .start:
            return "Starts With"
        case .end:
            return "End with"
        case .re:
            return "Regex"
        }
    }
}


struct FilterBarView: View {
    @Binding var column: ColumnFilter
    @Binding var filterString: String
    @Binding var caseSensitive: Bool
    @Binding var matchMode: MatchMode
    @AppStorage("togglerFinder") var showFinder: Bool = false
    
    init(filterString: Binding<String>, column: Binding<ColumnFilter>,
         matchMode: Binding<MatchMode>, caseSensitive: Binding<Bool>) {
        _filterString = filterString
        _column = column
        _matchMode = matchMode
        _caseSensitive = caseSensitive
    }
    
    var body: some View {
        HStack {
            Picker(selection: $column) {
                ForEach(ColumnFilter.allCases, id: \.self) { col in
                    Text("\(col.desc)").tag(col)
                }
            } label: {}
            .frame(width: 100)
            
            TextField("Filter(press Enter to search, not press done)", text: $filterString)
                .textFieldStyle(.roundedBorder)
            Divider()
            
            Button("Aa") {
                caseSensitive.toggle()
            }
            .buttonStyle(.plain)
            .foregroundColor(caseSensitive ? .blue : .secondary)
            .help("Case sensitive")
            
            Divider()
            
            Picker(selection: $matchMode) {
                ForEach(MatchMode.allCases, id: \.self) { mode in
                    Text("\(mode.desc)")
                }
            } label: {}
            .frame(width: 120)
            
            Divider()
            
            Button("Done") {
                withAnimation {
                    showFinder.toggle()
                }
            }
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
    }
}
