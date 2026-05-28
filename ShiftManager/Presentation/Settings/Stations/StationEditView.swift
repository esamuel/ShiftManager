import SwiftUI

public struct StationEditView: View {
    @Environment(\.dismiss) private var dismiss

    private let original: StationModel?
    private let onSave: (String, Double, String?) async -> Void

    @State private var name: String
    @State private var wageText: String
    @State private var colorHex: String

    private static let palette: [(name: String, hex: String)] = [
        ("Purple", "8E7CFF"),
        ("Blue",   "4A90E2"),
        ("Teal",   "2EC4B6"),
        ("Green",  "5BBA6F"),
        ("Yellow", "F2C14E"),
        ("Orange", "F08A4B"),
        ("Red",    "E0584F"),
        ("Pink",   "F074AD")
    ]

    public init(station: StationModel?, onSave: @escaping (String, Double, String?) async -> Void) {
        self.original = station
        self.onSave = onSave
        _name = State(initialValue: station?.name ?? "")
        _wageText = State(initialValue: station.map { String(format: "%.2f", $0.hourlyWage) } ?? "")
        _colorHex = State(initialValue: station?.colorHex ?? Self.palette[0].hex)
    }

    public var body: some View {
        NavigationView {
            Form {
                Section("Station name".localized) {
                    TextField("Station name".localized, text: $name)
                        .textInputAutocapitalization(.words)
                }

                Section("Hourly wage".localized) {
                    TextField("0.00", text: $wageText)
                        .keyboardType(.decimalPad)
                }

                Section("Color".localized) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 36), spacing: 12)], spacing: 12) {
                        ForEach(Self.palette, id: \.hex) { item in
                            ColorDot(hex: item.hex, isSelected: colorHex == item.hex)
                                .onTapGesture { colorHex = item.hex }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(original == nil ? "Add Station".localized : "Edit Station".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel".localized) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save".localized) {
                        Task {
                            let wage = Double(wageText.replacingOccurrences(of: ",", with: ".")) ?? 0
                            await onSave(name, wage, colorHex)
                            dismiss()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct ColorDot: View {
    let hex: String
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 32, height: 32)
            if isSelected {
                Circle()
                    .stroke(Color.primary, lineWidth: 2)
                    .frame(width: 38, height: 38)
            }
        }
    }

    private var color: Color {
        guard let value = Int(hex, radix: 16) else { return .gray }
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b)
    }
}
