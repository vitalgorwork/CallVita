import SwiftUI

struct ContentView: View {
    @State private var isCalling = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("CallVita")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Private internet calls")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: {
                    CallManager.shared.startCall()
                    isCalling = true
                }) {
                    Text("Press to Call")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isCalling ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .disabled(isCalling)
                .padding(.horizontal, 24)

                Spacer()
            }
            .navigationDestination(isPresented: $isCalling) {
                CallScreenView(isCalling: $isCalling)
            }
        }
    }
}
