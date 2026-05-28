import SwiftUI

public struct StationsListView: View {
    @StateObject private var viewModel = StationsViewModel()
    @State private var editingStation: StationModel?
    @State private var showingNew = false

    public init() {}

    public var body: some View {
        Group {
            if viewModel.isLoading && viewModel.stations.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.stations.isEmpty {
                emptyState
            } else {
                stationList
            }
        }
        .navigationTitle("Work Stations".localized)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingNew = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Station".localized)
            }
        }
        .sheet(isPresented: $showingNew) {
            StationEditView(station: nil) { name, wage, color in
                await viewModel.create(name: name, hourlyWage: wage, colorHex: color)
            }
        }
        .sheet(item: $editingStation) { station in
            StationEditView(station: station) { name, wage, color in
                var updated = station
                updated.name = name
                updated.hourlyWage = wage
                updated.colorHex = color
                await viewModel.update(updated)
            }
        }
        .task { await viewModel.load() }
        .refreshOnLanguageChange()
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "briefcase")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Work Stations".localized)
                .font(.headline)
            Text("Create a station for each role with a different hourly wage.".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button {
                showingNew = true
            } label: {
                Label("Add Station".localized, systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var stationList: some View {
        List {
            ForEach(viewModel.stations) { station in
                Button {
                    editingStation = station
                } label: {
                    StationRow(station: station)
                }
                .buttonStyle(.plain)
            }
            .onDelete { offsets in
                Task { await viewModel.delete(at: offsets) }
            }
        }
    }
}

private struct StationRow: View {
    let station: StationModel

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: station.colorHex) ?? .purple)
                .frame(width: 12, height: 12)
            VStack(alignment: .leading, spacing: 2) {
                Text(station.name)
                    .font(.body)
                    .foregroundColor(.primary)
                Text(String(format: "%.2f / %@".localized, station.hourlyWage, "hour".localized))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

private extension Color {
    init?(hex: String?) {
        guard let hex = hex?.trimmingCharacters(in: CharacterSet(charactersIn: "# ")),
              hex.count == 6,
              let value = Int(hex, radix: 16) else { return nil }
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
