import SwiftUI

struct PrimaryButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColors.teal)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct SecondaryTextButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(AppColors.muted)
        }
        .buttonStyle(.plain)
    }
}

struct PageIndicator: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == current ? AppColors.teal : AppColors.cardElevated)
                    .frame(width: index == current ? 28 : 10, height: 4)
            }
        }
    }
}

struct DarkCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct ScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background.ignoresSafeArea())
    }
}

extension View {
    func screenBackground() -> some View {
        modifier(ScreenBackground())
    }
}

struct ProfileAvatar: View {
    let imageData: Data?
    let name: String
    var size: CGFloat = 48

    var body: some View {
        Group {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(String(name.prefix(1)))
                    .font(size >= 60 ? .title.bold() : .title2.bold())
                    .foregroundStyle(AppColors.teal)
            }
        }
        .frame(width: size, height: size)
        .background(AppColors.teal.opacity(0.25))
        .clipShape(Circle())
    }
}
