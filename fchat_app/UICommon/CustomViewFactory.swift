
import Foundation
import StreamVideo
import StreamVideoSwiftUI
import SwiftUI

final class CustomViewFactory: ViewFactory {

    static let shared = CustomViewFactory()

    func makeOutgoingCallView(viewModel: CallViewModel) -> some View {
        CustomOutgoingCallView(
            viewModel: viewModel,
            outgoingCallMembers: viewModel.outgoingCallMembers,
            callTopView: makeCallTopView(viewModel: viewModel),
            callControls: makeCallControlsView(viewModel: viewModel)
        )
    }
}
