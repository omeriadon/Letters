    //
    //  ContentView.swift
    //  Letters
    //
    //  Created by Adon Omeri on 13/5/2025.
    //

import SwiftUI
import Defaults
import ColorfulX

struct ContentView: View {
    
    @State private var text = ""
    @FocusState private var isTextFieldFocused: Bool
    

    
    @State private var showSettings = false
    
    @Default(.fontWidth) var fontWidth
    
    @Default(.fontDesign) var fontDesign
    
    @Default(.fontWeight) var fontWeight
    
    @Default(.colorfulViewOpacity) var colorfulViewOpacity
    
    @Default(.showAnimation) var showAnimation
    
    @Default(.useSimpleMode) var useSimpleMode
    
    @Default(.letKeyboardBeChanged) var letKeyboardBeChanged
    
    @Default(.useNumbersKeyboard) var useNumbersKeyboard
    
#if os(iOS)
    @State var colors: [Color] = ColorfulPreset.appleIntelligence.colors.map { Color(uiColor: $0) }
#else
    @State var colors: [Color] = ColorfulPreset.appleIntelligence.colors.map { Color(nsColor: $0) }
#endif
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                Color.black
                
                ColorfulView(color: $colors)
                    .opacity(colorfulViewOpacity)
                
                TextField("Text here", text: $text)
                    .autocorrectionDisabled()
#if os(iOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(useNumbersKeyboard ? .numberPad : .alphabet)
#endif
                    .scrollDismissesKeyboard(.never)
                    .onSubmit {
                        isTextFieldFocused = true
                    }
                    .opacity(0)
                    .focused($isTextFieldFocused)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isTextFieldFocused = true
                        }
                    }
                    .onChange(of: text) { _ , newValue in
                        if useSimpleMode {
                            text = newValue.filter { $0.isLetter || $0.isNumber}

                        } else {
                            text = newValue.filter { $0.isLetter || $0.isNumber || $0 == " "}
                        }
                    }
                    .onChange(of: isTextFieldFocused) { _ , newValue in
                        if !newValue && !showSettings {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                isTextFieldFocused = true
                            }                        }
                    }
                GeometryReader { geometry in
                    VStack {
                        Group {
                            if useSimpleMode {
                                Text(String(text.last ?? String.Element("-")))
                            } else {
                                Text(text.lastWord)
                            }
                        }
                        .padding()
                        
                        .font(.system(size: min(geometry.size.width, geometry.size.height) * 0.9))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .minimumScaleFactor(0.05)
                        .multilineTextAlignment(.center)
                        
                        .fontWeight(fontWeight.fontWeight)
                        .fontDesign(fontDesign.fontDesign)
                        .fontWidth(fontWidth.fontWidth)
                        
                        .contentTransition(.numericText())
                        .animation(showAnimation ? .default : nil, value: text)
                        .animation(.default, value: fontWidth)
                        .animation(.default, value: fontWeight)
                        .animation(.default, value: fontDesign)
                        .animation(.default, value: useSimpleMode)
                        
                        
                        
#if !os(macOS)
                        Spacer()
                            .frame(height: ( geometry.size.height / 2 ) - 50 )
#endif
                    }
                }
            }
            .ignoresSafeArea()
#if os(iOS)
            .sheet(isPresented: $showSettings) {
                
                SettingsView()
                    .scrollBounceBehavior(.basedOnSize)
                    .presentationCornerRadius(50)
                    .presentationDetents([.large])
                    .presentationBackground(.ultraThinMaterial)
                
            }
#else
            .popover(isPresented: $showSettings, content: {
                SettingsView()
                    .frame(minWidth: 500, minHeight: 300)
                    .background(UltraThinView())

            })
#endif
            
            .onChange(of: showSettings) { _ , newValue in
                if newValue == false {
                    isTextFieldFocused = true
                } else {
                    isTextFieldFocused = false
                }
                
            }
            .toolbarBackground(.ultraThinMaterial)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                
            }
#if os(iOS)
            .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        HStack {
                            if letKeyboardBeChanged {
                                
                                Button {
                                    if useNumbersKeyboard == true {
                                        isTextFieldFocused = false
                                        useNumbersKeyboard = false
                                        isTextFieldFocused = true
                                    } else {
                                        isTextFieldFocused = false
                                        useNumbersKeyboard = true
                                        isTextFieldFocused = true
                                    }
                                } label: {
                                    Image(systemName: "keyboard")
                                }
                                .padding(.horizontal)
                                
                            }
                            
                            Button {
                                text += " "
                            } label: {
                                Image(systemName: "space")
                            }
                            .padding(.horizontal)
                    }
                }

                
                
                
            }
#endif
            
        }
    }
}


#Preview {
    ContentView()
}


extension String {
        /// Splits on spaces and returns the last segment (or empty if none)
    var lastWord: String {
        if self.last == " " {
            return " "
        }
        let parts = self.split(separator: " ")
        return parts.last.map(String.init) ?? ""
    }
}


extension Defaults.Keys {
    
    static let fontDesign = Key<SerializableFontDesign>("fontDesign", default: .default)
    
    static let fontWeight = Key<SerializableFontWeight>("fontWeight", default: .regular)
    
    static let fontWidth = Key<SerializableFontWidth>("fontWidth", default: .standard)
    
    static let colorfulViewOpacity = Key<Double>("colorfulViewOpacity", default: 0.3)
    
    static let showAnimation = Key<Bool>("showAnimation", default: true)
    
    static let useSimpleMode = Key<Bool>("useSimpleMode", default: true)
    
    static let useNumbersKeyboard = Key<Bool>("useNumbersKeyboard", default: false)
    
    static let letKeyboardBeChanged = Key<Bool>("letKeyboardBeChanged", default: true)
    
}


enum SerializableFontDesign: String, Defaults.Serializable, CaseIterable {
    case `default`, monospaced, rounded, serif
    
    var fontDesign: Font.Design {
        switch self {
            case .default: return .default
            case .monospaced: return .monospaced
            case .rounded: return .rounded
            case .serif: return .serif
        }
    }
}

enum SerializableFontWeight: String,  Defaults.Serializable, CaseIterable {
    case medium, regular, semibold, bold, black, heavy, light, thin, ultralight
    
    var fontWeight: Font.Weight {
        switch self {
            case .ultralight:
                    .ultraLight
            case .thin:
                    .thin
            case .light:
                    .light
            case .regular:
                    .regular
            case .medium:
                    .medium
            case .semibold:
                    .semibold
            case .bold:
                    .bold
            case .heavy:
                    .heavy
            case .black:
                    .black

        }
    }
}

enum SerializableFontWidth: String, Defaults.Serializable, CaseIterable {
    case standard, expanded, compressed, condensed
    
    var fontWidth: Font.Width {
        switch self {
            case .expanded:
                    .expanded
            case .standard:
                    .standard
            case .condensed:
                    .condensed
            case .compressed:
                    .compressed
        }
    }
}


extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }
}

struct SettingsView: View {
    
    @Default(.fontWidth) var fontWidth
    
    @Default(.fontDesign) var fontDesign
    
    @Default(.fontWeight) var fontWeight
    
    @Default(.colorfulViewOpacity) var colorfulViewOpacity
    
    @Default(.showAnimation) var showAnimation
    
    @Default(.useSimpleMode) var useSimpleMode
    
    @Default(.letKeyboardBeChanged) var letKeyboardBeChanged
    
    @Default(.useNumbersKeyboard) var useNumbersKeyboard

    var body: some View {
        List {
            Group {
                Section {
                    Picker(selection:
                            Binding(
                                get: { fontWidth },
                                set: { fontWidth = $0 }
                            ), content: {
                                ForEach(SerializableFontWidth.allCases, id: \.self) { item in
                                    Text(item.rawValue.capitalized).tag(item)
                                }
                            }, label: {
                                Label("Font Width", systemImage: "arrow.left.and.right")
                            })
                }
                
                Section {
                    Picker(selection:
                            Binding(
                                get: { fontWeight },
                                set: { fontWeight = $0 }
                            ), content: {
                                ForEach(SerializableFontWeight.allCases, id: \.self) { item in
                                    Text(item.rawValue.capitalized).tag(item)
                                }
                            }, label: {
                                Label("Font Weight", systemImage: "lineweight")
                            })
                }
                
                Section {
                    Picker(selection:
                            Binding(
                                get: { fontDesign },
                                set: { fontDesign = $0 }
                            ), content: {
                                ForEach(SerializableFontDesign.allCases, id: \.self) { item in
                                    Text(item.rawValue.capitalized).tag(item)
                                }
                            }, label: {
                                Label("Font Design", systemImage: "textformat.alt")
                            })
                }
                
                Section("Background Gradients Opacity") {
                    HStack {
                        Text(String(colorfulViewOpacity.rounded(toPlaces: 1)))
                            .contentTransition(.numericText())
                            .animation(.default, value: colorfulViewOpacity)
                            .frame(width: 25)
                        Slider(value: $colorfulViewOpacity, in: 0...1)
                    }
                }
                
                Section {
                    Toggle("Show animation", isOn: $showAnimation)
                }
                
                Section {
                    Toggle("Use simple mode", isOn: $useSimpleMode)
                }
#if os(iOS)
                Section {
                    Toggle("Let keyboard be toggled", isOn: $letKeyboardBeChanged)
                }
                
                Section {
                    Picker(
                        selection: Binding(
                            get: { useNumbersKeyboard },
                            set: { useNumbersKeyboard = $0 }
                        ),
                        label:
                            Label("Keyboard Type", systemImage: "keyboard")
                        
                    ) {
                        ForEach(["Alphanumeric", "Numbers"], id: \.self) { item in
                            Text(item).tag(item == "Alphanumeric" ? false : true)
                        }
                    }
                }
#endif
            }
            .listRowBackground(UltraThinView())
            
            
        }
#if os(macOS)
        .background(UltraThinView())
#endif
        .scrollContentBackground(.hidden)
        .listStyle(.sidebar)
        
    }
}

struct UltraThinView: View {
    var body: some View {
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
        }
    }
}

