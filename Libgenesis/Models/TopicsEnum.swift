//
//  TopicsEnum.swift
//  Libgenesis
//
//  Created by Fish on 21/9/2024.
//

import Foundation

// Technology Topics
enum TechnologyTopic: Int, CaseIterable, Identifiable, Codable {
    case Automation = 211
    case AerospaceEquipment = 212
    case WaterTreatment = 213
    case MilitaryEquipment = 214
    case MilitaryEquipmentWeapon = 215
    case Publishing = 216
    case SpaceScience = 217
    case LightIndustry = 218
    case Materials = 219
    case MechanicalEngineering = 220
    case Metallurgy = 221
    case Metrology = 222
    case SafetyAndSecurity = 223
    case Nanotechnology = 224
    case OilAndGasTechnologies = 225
    case Pipelines = 226
    case RegulatoryLiterature = 227
    case PatentBusiness = 228
    case FoodManufacturing = 229
    case Instrument = 230
    case MetallurgyIndustry = 231
    case IndustrialEquipmentAndTechnology = 232
    case Missiles = 233
    case Communication = 234
    case Telecommunications = 235
    case Construction = 236
    case VentilationAndAirConditioning = 238
    case RenovationAndInteriorDesign = 239
    case Saunas = 240
    case CementIndustry = 241
    case Heat = 242
    case FuelTechnology = 243
    case Transport = 244
    case Aviation = 245
    case CarsAndMotorcycles = 246
    case Rail = 247
    case Ships = 248
    case Refrigeration = 249
    case Electronics = 250
    case Hardware = 251
    case FiberOptics = 252
    case HomeElectronics = 253
    case MicroprocessorTechnology = 254
    case SignalProcessing = 255
    case Radio = 256
    case Robotics = 257
    case VLSI = 258
    case TVVideo = 259
    case ElectronicsTelecommunications = 260
    case RenewableEnergy = 263
    case Energy = 262

    var id: Self { self }
    
    var desc: String {
        switch self {
        case .Automation:
            return "Automation"
        case .AerospaceEquipment:
            return "Aerospace Equipment"
        case .WaterTreatment:
            return "Water Treatment"
        case .MilitaryEquipment:
            return "Military Equipment"
        case .MilitaryEquipmentWeapon:
            return "Military equipment: Weapon"
        case .Publishing:
            return "Publishing"
        case .SpaceScience:
            return "Space Science"
        case .LightIndustry:
            return "Light Industry"
        case .Materials:
            return "Materials"
        case .MechanicalEngineering:
            return "Mechanical Engineering"
        case .Metallurgy:
            return "Metallurgy"
        case .Metrology:
            return "Metrology"
        case .SafetyAndSecurity:
            return "Safety and Security"
        case .Nanotechnology:
            return "Nanotechnology"
        case .OilAndGasTechnologies:
            return "Oil and Gas Technologies"
        case .Pipelines:
            return "Oil and Gas Technologies: Pipelines"
        case .RegulatoryLiterature:
            return "Regulatory Literature"
        case .PatentBusiness:
            return "Patent Business. Ingenuity. Innovation"
        case .FoodManufacturing:
            return "Food Manufacturing"
        case .Instrument:
            return "Instrument"
        case .MetallurgyIndustry:
            return "Industry: Metallurgy"
        case .IndustrialEquipmentAndTechnology:
            return "Industrial Equipment and Technology"
        case .Missiles:
            return "Missiles"
        case .Communication:
            return "Communication"
        case .Telecommunications:
            return "Communication: Telecommunications"
        case .Construction:
            return "Construction"
        case .VentilationAndAirConditioning:
            return "Construction: Ventilation and Air Conditioning"
        case .RenovationAndInteriorDesign:
            return "Construction: Renovation and Interior Design"
        case .Saunas:
            return "Construction: Renovation and Interior Design: Saunas"
        case .CementIndustry:
            return "Construction: Cement Industry"
        case .Heat:
            return "Heat"
        case .FuelTechnology:
            return "Fuel Technology"
        case .Transport:
            return "Transport"
        case .Aviation:
            return "Transportation: Aviation"
        case .CarsAndMotorcycles:
            return "Transportation: Cars, Motorcycles"
        case .Rail:
            return "Transportation: Rail"
        case .Ships:
            return "Transportation: Ships"
        case .Refrigeration:
            return "Refrigeration"
        case .Electronics:
            return "Electronics"
        case .Hardware:
            return "Electronics: Hardware"
        case .FiberOptics:
            return "Electronics: Fiber Optics"
        case .HomeElectronics:
            return "Electronics: Home Electronics"
        case .MicroprocessorTechnology:
            return "Electronics: Microprocessor Technology"
        case .SignalProcessing:
            return "Electronics: Signal Processing"
        case .Radio:
            return "Electronics: Radio"
        case .Robotics:
            return "Electronics: Robotics"
        case .VLSI:
            return "Electronics: VLSI"
        case .TVVideo:
            return "Electronics: TV, Video"
        case .ElectronicsTelecommunications:
            return "Electronics: Telecommunications"
        case .RenewableEnergy:
            return "Energy: Renewable Energy"
        case .Energy:
            return "Energy"
        }
    }
}

// Art Topics
enum ArtTopic: Int, CaseIterable, Identifiable, Codable {
    case DesignArchitecture = 58
    case GraphicArts = 59
    case Cinema = 60
    case Music = 61
    case MusicGuitar = 62
    case Photo = 63

    var id: Self { self }
    
    var desc: String {
        switch self {
        case .DesignArchitecture:
            return "Design: Architecture"
        case .GraphicArts:
            return "Graphic Arts"
        case .Cinema:
            return "Cinema"
        case .Music:
            return "Music"
        case .MusicGuitar:
            return "Music: Guitar"
        case .Photo:
            return "Photo"
        }
    }
}

// Biology Topics
enum BiologyTopic: Int, CaseIterable, Identifiable, Codable {
    case Estestvoznananie = 13
    case Anthropology = 14
    case AnthropologyEvolution = 15
    case Biostatistics = 16
    case Biotechnology = 17
    case Biophysics = 18
    case Biochemistry = 19
    case BiochemistryEnologist = 20
    case Virology = 21
    case Genetics = 22
    case Zoology = 23
    case ZoologyPaleontology = 24
    case ZoologyFish = 25
    case Microbiology = 26
    case Molecular = 27
    case MolecularBioinformatics = 28
    case PlantsAgricultureForestry = 30
    case Ecology = 31

    var id: Self { self }
    
    var desc: String {
        switch self {
        case .Estestvoznananie:
            return "Estestvoznananie"
        case .Anthropology:
            return "Anthropology"
        case .AnthropologyEvolution:
            return "Anthropology: Evolution"
        case .Biostatistics:
            return "Biostatistics"
        case .Biotechnology:
            return "Biotechnology"
        case .Biophysics:
            return "Biophysics"
        case .Biochemistry:
            return "Biochemistry"
        case .BiochemistryEnologist:
            return "Biochemistry: Enologist"
        case .Virology:
            return "Virology"
        case .Genetics:
            return "Genetics"
        case .Zoology:
            return "Zoology"
        case .ZoologyPaleontology:
            return "Zoology: Paleontology"
        case .ZoologyFish:
            return "Zoology: Fish"
        case .Microbiology:
            return "Microbiology"
        case .Molecular:
            return "Molecular"
        case .MolecularBioinformatics:
            return "Molecular: Bioinformatics"
        case .PlantsAgricultureForestry:
            return "Plants: Agriculture and Forestry"
        case .Ecology:
            return "Ecology"
        }
    }
}

// Business Topics
enum BusinessTopic: Int, CaseIterable, Identifiable, Codable {
    case Accounting = 2
    case ECommerce = 11
    case Logistics = 3
    case Management = 6
    case Marketing = 4
    case MarketingAdvertising = 5
    case ProjectManagement = 7
    case MLM = 8
    case BusinessEthics = 9
    case Trading = 10

    var id: Self { self }
    
    var desc: String {
        switch self {
        case .Accounting:
            return "Accounting"
        case .ECommerce:
            return "E-Commerce"
        case .Logistics:
            return "Logistics"
        case .Management:
            return "Management"
        case .Marketing:
            return "Marketing"
        case .MarketingAdvertising:
            return "Marketing: Advertising"
        case .ProjectManagement:
            return "Management: Project Management"
        case .MLM:
            return "MLM"
        case .BusinessEthics:
            return "Responsibility and Business Ethics"
        case .Trading:
            return "Trading"
        }
    }
}

// Chemistry Topics
enum ChemistryTopic: Int, CaseIterable, Identifiable, Codable {
    case AnalyticalChemistry = 297
    case Chemical = 304
    case InorganicChemistry = 299
    case Materials = 298
    case OrganicChemistry = 300
    case PyrotechnicsAndExplosives = 301
    case Pharmacology = 302
    case PhysicalChemistry = 303

    var id: Self { self }
    
    var desc: String {
        switch self {
        case .AnalyticalChemistry:
            return "Analytical Chemistry"
        case .Chemical:
            return "Chemical"
        case .InorganicChemistry:
            return "Inorganic Chemistry"
        case .Materials:
            return "Materials"
        case .OrganicChemistry:
            return "Organic Chemistry"
        case .PyrotechnicsAndExplosives:
            return "Pyrotechnics and Explosives"
        case .Pharmacology:
            return "Pharmacology"
        case .PhysicalChemistry:
            return "Physical Chemistry"
        }
    }
}

// Computer Topics
enum ComputerTopic: Int, CaseIterable, Identifiable, Codable {
    case AlgorithmsAndDataStructures = 71
    case CryptographyADS = 72
    case ImageProcessing = 73
    case PatternRecognition = 74
    case DigitalWatermarks = 75
    case Cybernetics = 80
    case ArtificialIntelligence = 81
    case Cryptography = 82
    case Databases = 76
    case InformationSystems = 78
    case ECBusinesses = 79
    case LecturesMonographs = 83
    case Media = 84
    case Networking = 99
    case Internet = 100
    case OperatingSystems = 85
    case OrganizationDataProcessing = 86
    case Programming = 87
    case LibrariesAPI = 88
    case ProgrammingGames = 89
    case Compilers = 90
    case ModelingLanguages = 91
    case ProgrammingLanguages = 92
    case TeXLaTeX = 93
    case Security = 77
    case OfficeSoftware = 94
    case AdobeProducts = 95
    case MacromediaProducts = 96
    case CAD = 97
    case ScientificComputing = 98
    case SystemAdministration = 101
    case WebDesign = 70

    var id: Self { self }

    var desc: String {
        switch self {
        case .AlgorithmsAndDataStructures:
            return "Algorithms and Data Structures"
        case .CryptographyADS:
            return "Algorithms and Data Structures: Cryptography"
        case .ImageProcessing:
            return "Algorithms and Data Structures: Image Processing"
        case .PatternRecognition:
            return "Algorithms and Data Structures: Pattern Recognition"
        case .DigitalWatermarks:
            return "Algorithms and Data Structures: Digital Watermarks"
        case .Cybernetics:
            return "Cybernetics"
        case .ArtificialIntelligence:
            return "Cybernetics: Artificial Intelligence"
        case .Cryptography:
            return "Cryptography"
        case .Databases:
            return "Databases"
        case .InformationSystems:
            return "Information Systems"
        case .ECBusinesses:
            return "Information Systems: EC Businesses"
        case .LecturesMonographs:
            return "Lectures, Monographs"
        case .Media:
            return "Media"
        case .Networking:
            return "Networking"
        case .Internet:
            return "Networking: Internet"
        case .OperatingSystems:
            return "Operating Systems"
        case .OrganizationDataProcessing:
            return "Organization and Data Processing"
        case .Programming:
            return "Programming"
        case .LibrariesAPI:
            return "Programming: Libraries API"
        case .ProgrammingGames:
            return "Programming: Games"
        case .Compilers:
            return "Programming: Compilers"
        case .ModelingLanguages:
            return "Programming: Modeling Languages"
        case .ProgrammingLanguages:
            return "Programming: Programming Languages"
        case .TeXLaTeX:
            return "Programs: TeX, LaTeX"
        case .Security:
            return "Security"
        case .OfficeSoftware:
            return "Software: Office Software"
        case .AdobeProducts:
            return "Software: Adobe Products"
        case .MacromediaProducts:
            return "Software: Macromedia Products"
        case .CAD:
            return "Software: CAD"
        case .ScientificComputing:
            return "Software: Systems: Scientific Computing"
        case .SystemAdministration:
            return "System Administration"
        case .WebDesign:
            return "Web-design"
        }
    }
}

// Geography Topics
enum GeographyTopic: Int, CaseIterable, Identifiable, Codable {
    case GeodesyCartography = 33
    case LocalHistory = 34
    case LocalHistoryTourism = 35
    case MeteorologyClimatology = 36
    case Russia = 37

    var id: Self { self }

    var desc: String {
        switch self {
        case .GeodesyCartography:
            return "Geodesy. Cartography"
        case .LocalHistory:
            return "Local History"
        case .LocalHistoryTourism:
            return "Local History: Tourism"
        case .MeteorologyClimatology:
            return "Meteorology, Climatology"
        case .Russia:
            return "Russia"
        }
    }
}

// Geology Topics
enum GeologyTopic: Int, CaseIterable, Identifiable, Codable {
    case Gidrogeology = 39
    case Mining = 40

    var id: Self { self }

    var desc: String {
        switch self {
        case .Gidrogeology:
            return "Gidrogeology"
        case .Mining:
            return "Mining"
        }
    }
}

// Economy Topics
enum EconomyTopic: Int, CaseIterable, Identifiable, Codable {
    case Econometrics = 310
    case Investing = 306
    case Markets = 309
    case MathematicalEconomics = 307
    case Popular = 308

    var id: Self { self }

    var desc: String {
        switch self {
        case .Econometrics:
            return "Econometrics"
        case .Investing:
            return "Investing"
        case .Markets:
            return "Markets"
        case .MathematicalEconomics:
            return "Mathematical Economics"
        case .Popular:
            return "Popular"
        }
    }
}

// Education Topics
enum EducationTopic: Int, CaseIterable, Identifiable, Codable {
    case Elementary = 187
    case InternationalConferences = 185
    case SelfHelpBooks = 186
    case ThesesAbstracts = 184

    var id: Self { self }

    var desc: String {
        switch self {
        case .Elementary:
            return "Elementary"
        case .InternationalConferences:
            return "International Conferences and Symposiums"
        case .SelfHelpBooks:
            return "Self-help Books"
        case .ThesesAbstracts:
            return "Theses Abstracts"
        }
    }
}

// Jurisprudence Topics
enum JurisprudenceTopic: Int, CaseIterable, Identifiable, Codable {
    case CriminologyForensicScience = 311
    case CriminologyCourtExamination = 312
    case Law = 313

    var id: Self { self }

    var desc: String {
        switch self {
        case .CriminologyForensicScience:
            return "Criminology, Forensic Science"
        case .CriminologyCourtExamination:
            return "Criminology: Court Examination"
        case .Law:
            return "Law"
        }
    }
}

// Housekeeping Topics
enum HousekeepingTopic: Int, CaseIterable, Identifiable, Codable {
    case Aquaria = 42
    case Astrology = 43
    case BeautyImage = 48
    case BenefitsHomebrew = 52
    case Collecting = 47
    case Cooking = 49
    case FashionJewelry = 50
    case GamesBoardGames = 45
    case GamesChess = 46
    case Garden = 56
    case Handicraft = 54
    case HandicraftCuttingSewing = 55
    case HuntingGameManagement = 51
    case Pet = 44
    case ProfessionsTrades = 53

    var id: Self { self }

    var desc: String {
        switch self {
        case .Aquaria:
            return "Aquaria"
        case .Astrology:
            return "Astrology"
        case .BeautyImage:
            return "Beauty, Image"
        case .BenefitsHomebrew:
            return "Benefits Homebrew"
        case .Collecting:
            return "Collecting"
        case .Cooking:
            return "Cooking"
        case .FashionJewelry:
            return "Fashion, Jewelry"
        case .GamesBoardGames:
            return "Games: Board Games"
        case .GamesChess:
            return "Games: Chess"
        case .Garden:
            return "Garden, Gardening"
        case .Handicraft:
            return "Handicraft"
        case .HandicraftCuttingSewing:
            return "Handicraft: Cutting and Sewing"
        case .HuntingGameManagement:
            return "Hunting and Game Management"
        case .Pet:
            return "Pet"
        case .ProfessionsTrades:
            return "Professions and Trades"
        }
    }
}

// History Topics
enum HistoryTopic: Int, CaseIterable, Identifiable, Codable {
    case AmericanStudies = 65
    case Archaeology = 66
    case MilitaryHistory = 67

    var id: Self { self }
    
    var desc: String {
        switch self {
        case .AmericanStudies:
            return "American Studies"
        case .Archaeology:
            return "Archaeology"
        case .MilitaryHistory:
            return "Military History"
        }
    }
}

// Linguistics Topics
enum LinguisticsTopic: Int, CaseIterable, Identifiable, Codable {
    case ComparativeStudies = 318
    case Dictionaries = 322
    case Foreign = 315
    case ForeignEnglish = 316
    case ForeignFrench = 317
    case Linguistics = 319
    case Rhetoric = 320
    case RussianLanguage = 321
    case Stylistics = 323

    var id: Self { self }

    var desc: String {
        switch self {
        case .ComparativeStudies:
            return "Comparative Studies"
        case .Dictionaries:
            return "Dictionaries"
        case .Foreign:
            return "Foreign"
        case .ForeignEnglish:
            return "Foreign: English"
        case .ForeignFrench:
            return "Foreign: French"
        case .Linguistics:
            return "Linguistics"
        case .Rhetoric:
            return "Rhetoric"
        case .RussianLanguage:
            return "Russian Language"
        case .Stylistics:
            return "Stylistics"
        }
    }
}

// Literature Topics
enum LiteratureTopic: Int, CaseIterable, Identifiable, Codable {
    case Children = 106
    case Comics = 107
    case Detective = 105
    case Fantasy = 112
    case Fiction = 103
    case Folklore = 111
    case Library = 104
    case Literary = 108
    case Poetry = 109
    case Prose = 110

    var id: Self { self }

    var desc: String {
        switch self {
        case .Children:
            return "Children"
        case .Comics:
            return "Comics"
        case .Detective:
            return "Detective"
        case .Fantasy:
            return "Fantasy"
        case .Fiction:
            return "Fiction"
        case .Folklore:
            return "Folklore"
        case .Library:
            return "Library"
        case .Literary:
            return "Literary"
        case .Poetry:
            return "Poetry"
        case .Prose:
            return "Prose"
        }
    }
}

// Mathematics Topics
enum MathematicsTopic: Int, CaseIterable, Identifiable, Codable {
    case Algebra = 114
    case LinearAlgebra = 115
    case AlgorithmsAndDataStructures = 116
    case Analysis = 117
    case AppliedMathematics = 137
    case AutomaticControlTheory = 139
    case Combinatorics = 126
    case ComputationalMathematics = 120
    case ComputerAlgebra = 128
    case ContinuedFractions = 133
    case DifferentialEquations = 125
    case DiscreteMathematics = 124
    case DynamicalSystems = 123
    case Elementary = 146
    case FunctionalAnalysis = 144
    case FuzzyLogicAndApplications = 134
    case GameTheory = 141
    case GeometryAndTopology = 121
    case GraphTheory = 140
    case Lectures = 129
    case Logic = 130
    case MathematicalPhysics = 132
    case MathematicalStatistics = 131
    case NumberTheory = 143
    case NumericalAnalysis = 145
    case OperatorTheory = 142
    case OptimalControl = 135
    case OptimizationOperationsResearch = 136
    case Probability = 119
    case Puzzle = 122
    case SymmetryAndGroup = 138
    case TheComplexVariable = 127
    case WaveletsAndSignalProcessing = 118

    var id: Self { self }

    var desc: String {
        switch self {
        case .Algebra: return "Algebra"
        case .LinearAlgebra: return "Algebra: Linear Algebra"
        case .AlgorithmsAndDataStructures: return "Algorithms and Data Structures"
        case .Analysis: return "Analysis"
        case .AppliedMathematics: return "Applied Mathematics"
        case .AutomaticControlTheory: return "Automatic Control Theory"
        case .Combinatorics: return "Combinatorics"
        case .ComputationalMathematics: return "Computational Mathematics"
        case .ComputerAlgebra: return "Computer Algebra"
        case .ContinuedFractions: return "Continued fractions"
        case .DifferentialEquations: return "Differential Equations"
        case .DiscreteMathematics: return "Discrete Mathematics"
        case .DynamicalSystems: return "Dynamical Systems"
        case .Elementary: return "Elementary"
        case .FunctionalAnalysis: return "Functional Analysis"
        case .FuzzyLogicAndApplications: return "Fuzzy Logic and Applications"
        case .GameTheory: return "Game Theory"
        case .GeometryAndTopology: return "Geometry and Topology"
        case .GraphTheory: return "Graph Theory"
        case .Lectures: return "Lectures"
        case .Logic: return "Logic"
        case .MathematicalPhysics: return "Mathematical Physics"
        case .MathematicalStatistics: return "Mathematical Statistics"
        case .NumberTheory: return "Number Theory"
        case .NumericalAnalysis: return "Numerical Analysis"
        case .OperatorTheory: return "Operator Theory"
        case .OptimalControl: return "Optimal control"
        case .OptimizationOperationsResearch: return "Optimization. Operations Research."
        case .Probability: return "Probability"
        case .Puzzle: return "Puzzle"
        case .SymmetryAndGroup: return "Symmetry and group"
        case .TheComplexVariable: return "The complex variable"
        case .WaveletsAndSignalProcessing: return "Wavelets and signal processing"
        }
    }
}

// Medicine Topics
enum MedicineTopic: Int, CaseIterable, Identifiable, Codable {
    case AnatomyAndPhysiology = 148
    case AnesthesiologyAndIntensiveCare = 149
    case Cardiology = 159
    case ChineseMedicine = 160
    case ClinicalMedicine = 161
    case DentistryOrthodontics = 170
    case Diabetes = 155
    case DiseasesInternalMedicine = 151
    case Diseases = 150
    case Endocrinology = 176
    case ENT = 167
    case Epidemiology = 177
    case FengShui = 174
    case Histology = 152
    case Homeopathy = 153
    case Immunology = 156
    case InfectiousDiseases = 157
    case MolecularMedicine = 162
    case NaturalMedicine = 163
    case Neurology = 165
    case Oncology = 166
    case Ophthalmology = 168
    case Pediatrics = 169
    case Pharmacology = 173
    case PopularScientificLiterature = 164
    case SurgeryOrthopedics = 175
    case Therapy = 172
    case Trial = 171
    case Yoga = 158

    var id: Self { self }

    var desc: String {
        switch self {
        case .AnatomyAndPhysiology: return "Anatomy and physiology"
        case .AnesthesiologyAndIntensiveCare: return "Anesthesiology and Intensive Care"
        case .Cardiology: return "Cardiology"
        case .ChineseMedicine: return "Chinese Medicine"
        case .ClinicalMedicine: return "Clinical Medicine"
        case .DentistryOrthodontics: return "Dentistry, Orthodontics"
        case .Diabetes: return "Diabetes"
        case .DiseasesInternalMedicine: return "Diseases: Internal Medicine"
        case .Diseases: return "Diseases"
        case .Endocrinology: return "Endocrinology"
        case .ENT: return "ENT"
        case .Epidemiology: return "Epidemiology"
        case .FengShui: return "Feng Shui"
        case .Histology: return "Histology"
        case .Homeopathy: return "Homeopathy"
        case .Immunology: return "Immunology"
        case .InfectiousDiseases: return "Infectious diseases"
        case .MolecularMedicine: return "Molecular Medicine"
        case .NaturalMedicine: return "Natural Medicine"
        case .Neurology: return "Neurology"
        case .Oncology: return "Oncology"
        case .Ophthalmology: return "Ophthalmology"
        case .Pediatrics: return "Pediatrics"
        case .Pharmacology: return "Pharmacology"
        case .PopularScientificLiterature: return "Popular scientific literature"
        case .SurgeryOrthopedics: return "Surgery, Orthopedics"
        case .Therapy: return "Therapy"
        case .Trial: return "Trial"
        case .Yoga: return "Yoga"
        }
    }
}

// Other Social Sciences Topics
enum OtherSocialSciencesTopic: Int, CaseIterable, Identifiable, Codable {
    case Cultural = 191
    case Ethnography = 197
    case JournalismMedia = 190
    case Politics = 192
    case PoliticsInternationalRelations = 193
    case Philosophy = 195
    case PhilosophyCriticalThinking = 196
    case Sociology = 194

    var id: Self { self }

    var desc: String {
        switch self {
        case .Cultural: return "Cultural"
        case .Ethnography: return "Ethnography"
        case .JournalismMedia: return "Journalism, Media"
        case .Politics: return "Politics"
        case .PoliticsInternationalRelations: return "Politics: International Relations"
        case .Philosophy: return "Philosophy"
        case .PhilosophyCriticalThinking: return "Philosophy: Critical Thinking"
        case .Sociology: return "Sociology"
        }
    }
}

// Physics Topics
enum PhysicsTopic: Int, CaseIterable, Identifiable, Codable {
    case AstronomyAstrophysics = 266
    case Astronomy = 265
    case CrystalPhysics = 270
    case ElectricityAndMagnetism = 287
    case Electrodynamics = 288
    case GeneralCourses = 278
    case Geophysics = 267
    case Mechanics = 271
    case FluidMechanics = 274
    case MechanicsOfDeformableBodies = 273
    case NonlinearDynamicsAndChaos = 275
    case OscillationsAndWaves = 272
    case StrengthOfMaterials = 276
    case TheoryOfElasticity = 277
    case Optics = 279
    case PhysicsOfLasers = 284
    case PhysicsOfTheAtmosphere = 283
    case PlasmaPhysics = 285
    case QuantumMechanics = 268
    case QuantumPhysics = 269
    case SolidStatePhysics = 286
    case Spectroscopy = 280
    case TheoryOfRelativityAndGravitation = 281
    case ThermodynamicsAndStatisticalMechanics = 282

    var id: Self { self }

    var desc: String {
        switch self {
        case .AstronomyAstrophysics: return "Astronomy: Astrophysics"
        case .Astronomy: return "Astronomy"
        case .CrystalPhysics: return "Crystal Physics"
        case .ElectricityAndMagnetism: return "Electricity and Magnetism"
        case .Electrodynamics: return "Electrodynamics"
        case .GeneralCourses: return "General courses"
        case .Geophysics: return "Geophysics"
        case .Mechanics: return "Mechanics"
        case .FluidMechanics: return "Mechanics: Fluid Mechanics"
        case .MechanicsOfDeformableBodies: return "Mechanics: Mechanics of deformable bodies"
        case .NonlinearDynamicsAndChaos: return "Mechanics: Nonlinear dynamics and chaos"
        case .OscillationsAndWaves: return "Mechanics: Oscillations and Waves"
        case .StrengthOfMaterials: return "Mechanics: Strength of Materials"
        case .TheoryOfElasticity: return "Mechanics: Theory of Elasticity"
        case .Optics: return "Optics"
        case .PhysicsOfLasers: return "Physics of lasers"
        case .PhysicsOfTheAtmosphere: return "Physics of the Atmosphere"
        case .PlasmaPhysics: return "Plasma Physics"
        case .QuantumMechanics: return "Quantum Mechanics"
        case .QuantumPhysics: return "Quantum Physics"
        case .SolidStatePhysics: return "Solid State Physics"
        case .Spectroscopy: return "Spectroscopy"
        case .TheoryOfRelativityAndGravitation: return "Theory of Relativity and Gravitation"
        case .ThermodynamicsAndStatisticalMechanics: return "Thermodynamics and Statistical Mechanics"
        }
    }
}

// Physical Education and Sports Topics
enum PhysicalEducAndSportTopic: Int, CaseIterable, Identifiable, Codable {
    case Bodybuilding = 290
    case Bike = 292
    case Fencing = 295
    case MartialArts = 291
    case SportFishing = 294
    case Survival = 293

    var id: Self { self }

    var desc: String {
        switch self {
        case .Bodybuilding: return "Bodybuilding"
        case .Bike: return "Bike"
        case .Fencing: return "Fencing"
        case .MartialArts: return "Martial Arts"
        case .SportFishing: return "Sport fishing"
        case .Survival: return "Survival"
        }
    }
}

// Psychology Topics
enum PsychologyTopic: Int, CaseIterable, Identifiable, Codable {
    case ArtOfCommunication = 200
    case CreativeThinking = 204
    case Hypnosis = 199
    case LoveErotic = 201
    case NeuroLinguisticProgramming = 202
    case Pedagogy = 203

    var id: Self { self }

    var desc: String {
        switch self {
        case .ArtOfCommunication: return "The art of communication"
        case .CreativeThinking: return "Creative Thinking"
        case .Hypnosis: return "Hypnosis"
        case .LoveErotic: return "Love, erotic"
        case .NeuroLinguisticProgramming: return "Neuro-Linguistic Programming"
        case .Pedagogy: return "Pedagogy"
        }
    }
}

// Religion Topics
enum ReligionTopic: Int, CaseIterable, Identifiable, Codable {
    case Buddhism = 206
    case EsotericMystery = 209
    case Kabbalah = 207
    case Orthodoxy = 208

    var id: Self { self }

    var desc: String {
        switch self {
        case .Buddhism: return "Buddhism"
        case .EsotericMystery: return "Esoteric, Mystery"
        case .Kabbalah: return "Kabbalah"
        case .Orthodoxy: return "Orthodoxy"
        }
    }
}

// Science (General) Topics
enum ScienceTopic: Int, CaseIterable, Identifiable, Codable {
    case InternationalConferencesSymposiums = 179
    case ScienceOfScience = 180
    case ScientificPopular = 181
    case ScientificJournalism = 182

    var id: Self { self }

    var desc: String {
        switch self {
        case .InternationalConferencesSymposiums: return "International Conferences and Symposiums"
        case .ScienceOfScience: return "Science of Science"
        case .ScientificPopular: return "Scientific-popular"
        case .ScientificJournalism: return "Scientific and popular: Journalism"
        }
    }
}

