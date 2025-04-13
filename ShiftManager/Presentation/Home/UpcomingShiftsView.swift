import SwiftUI

public struct UpcomingShiftsView: View {
    @StateObject private var viewModel = UpcomingShiftsViewModel()
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Upcoming Shifts".localized)
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.upcomingShifts.isEmpty {
                Text("No upcoming shifts".localized)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(viewModel.upcomingShifts.keys.sorted()), id: \.self) { date in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(viewModel.formatDate(date))
                                    .font(.headline)
                                    .foregroundColor(.purple)
                                
                                if let shifts = viewModel.upcomingShifts[date], !shifts.isEmpty {
                                    ForEach(shifts) { shift in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(shift.title)
                                                    .font(.subheadline)
                                                    .foregroundColor(.primary)
                                                
                                                Text("\(viewModel.formatTime(shift.startTime)) - \(viewModel.formatTime(shift.endTime))")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Spacer()
                                            
                                            if shift.isSpecialDay {
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                            }
                                        }
                                        .padding(8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                } else {
                                    Text("No shifts scheduled".localized)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(8)
                                }
                            }
                            .padding(.horizontal)
                            
                            if date != viewModel.upcomingShifts.keys.sorted().last {
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .task {
            await viewModel.loadUpcomingShifts()
        }
    }
}

#Preview {
    UpcomingShiftsView()
        .padding()
} 