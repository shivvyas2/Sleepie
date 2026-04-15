import SwiftUI

struct TimerPickerSheet: View {
    @Binding var minutes: Int
    @Environment(\.dismiss) private var dismiss
    private let options = [15, 20, 30, 45, 60, 90, 120]

    var body: some View {
        NavigationStack {
            List(options, id: \.self) { option in
                Button {
                    minutes = option
                    dismiss()
                } label: {
                    HStack {
                        Text("\(option) minutes")
                            .foregroundStyle(SlipieColors.textPrimary)
                        Spacer()
                        if option == minutes {
                            Image(systemName: "checkmark")
                                .foregroundStyle(SlipieColors.accentEnd)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(SlipieColors.background)
            .navigationTitle("Sleep Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
