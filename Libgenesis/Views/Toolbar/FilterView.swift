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
                        if filter == .all {
                            formatFilters = [.all]
                        } else {
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
    @Binding var useFiction: Bool
    @Binding var useTopic: Bool
    @Binding var topicID: Int
    @Binding var topicName: String
    
    var TopicMenus: some View {
        Group {
            Group {
                Menu("Technology") {
                    ForEach(TechnologyTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
                Menu("Art") {
                    ForEach(ArtTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
                Menu("Biology") {
                    ForEach(BiologyTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
                Menu("Chemistry") {
                    ForEach(ChemistryTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
                Menu("Computer") {
                    ForEach(ComputerTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
                Menu("Geography") {
                    ForEach(GeographyTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
                Menu("Geology") {
                    ForEach(GeologyTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
                Menu("Jurisprudence") {
                    ForEach(JurisprudenceTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
                Menu("Housekeeping, leisure") {
                    ForEach(HousekeepingTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
                Menu("History") {
                    ForEach(HistoryTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
            }
            Group {
                Menu("Linguistics") {
                    ForEach(LinguisticsTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
                Menu("Literature") {
                    ForEach(LiteratureTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
                Menu("Mathematics") {
                    ForEach(MathematicsTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
                Menu("Medicine") {
                    ForEach(MedicineTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
                Menu("Other Social Science") {
                    ForEach(OtherSocialSciencesTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
                Menu("Physics") {
                    ForEach(PhysicsTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
            }
            Group {
                Menu("Physical Educ. and Sport") {
                    ForEach(PhysicalEducAndSportTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
                Menu("Psychology") {
                    ForEach(PsychologyTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
                Menu("Religion") {
                    ForEach(ReligionTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
                Menu("Science") {
                    ForEach(ScienceTopic.allCases, id: \.self) { tp in
                        Button("\(tp.desc)") {
                            topicName = tp.desc
                            topicID = tp.rawValue
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        Form {
            Button("Reset") {
                clearFilter()
            }
            
            HStack(alignment: .center) {
                Toggle("Search in topic:", isOn: $useTopic)
                Menu(topicName) {
                    TopicMenus
                }
                .disabled(useTopic == false)
            }
            .padding(.vertical, 5)
            .disabled(useFiction)
            
            Toggle(isOn: $useFiction) {
                Text("Search for fictions")
            }
            .disabled(useTopic)
            
            PageNumPicker()
            HStack(alignment: .top, spacing: 10) {
                ColumnFilterView(columnFilter: $columnFilter)
                AdvanceFilterView(formatFilters: $formatFilters)
            }
        }
        .padding()
        .frame(width: 400)

    }
    
    private func clearFilter() {
        columnFilter = .def
        formatFilters = [.all]
        useFiction = false
        useTopic = false
    }

}
