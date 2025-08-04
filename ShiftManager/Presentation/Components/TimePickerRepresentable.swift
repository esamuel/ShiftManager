import SwiftUI

/// A SwiftUI wrapper for UIDatePicker in `.time` mode, for localization-friendly time picking.
struct TimePickerRepresentable: UIViewRepresentable {
    @Binding var selectedTime: Date
    var locale: Locale = .current

    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.locale = locale
        picker.preferredDatePickerStyle = .wheels
        picker.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        return picker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = selectedTime
        uiView.locale = locale
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: TimePickerRepresentable
        init(_ parent: TimePickerRepresentable) {
            self.parent = parent
        }

        @objc func valueChanged(_ sender: UIDatePicker) {
            parent.selectedTime = sender.date
        }
    }
}
