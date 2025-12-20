import SwiftUI
import UniformTypeIdentifiers

struct ShiftBackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var shifts: [ShiftModel]
    
    init(shifts: [ShiftModel] = []) {
        self.shifts = shifts
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        shifts = try decoder.decode([ShiftModel].self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(shifts)
        return FileWrapper(regularFileWithContents: data)
    }
}
