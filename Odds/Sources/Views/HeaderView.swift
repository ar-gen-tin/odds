import SwiftUI

struct HeaderView: View {
    @Binding var showSearch: Bool
    @Binding var showSettings: Bool
    @Binding var searchQuery: String

    var body: some View {
        HStack {
            HStack(spacing: 6) {
                DiceLogo(size: 18)

                Text("odds")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(OddsTheme.text1)
            }

            Spacer()

            HStack(spacing: 6) {
                // P2 Fix: SF Symbols instead of Unicode
                Button {
                    showSearch.toggle()
                    if !showSearch { searchQuery = "" }
                    showSettings = false
                } label: {
                    HeaderIconButton(
                        icon: "magnifyingglass",
                        isActive: showSearch
                    )
                }
                .buttonStyle(.plain)

                Button {
                    showSettings.toggle()
                    showSearch = false
                    searchQuery = ""
                } label: {
                    HeaderIconButton(
                        icon: "gearshape",
                        isActive: showSettings
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .border(width: 1, edges: [.bottom], color: OddsTheme.border)
    }
}

struct DiceLogo: View {
    let size: CGFloat

    var body: some View {
        let dotSize = size * 0.22
        let padding = size * 0.2

        ZStack {
            RoundedRectangle(cornerRadius: size * 0.18)
                .stroke(OddsTheme.text1, lineWidth: 1.5)
                .frame(width: size, height: size)

            Circle()
                .fill(OddsTheme.lime)
                .frame(width: dotSize, height: dotSize)
                .offset(x: -(size / 2 - padding - dotSize / 2),
                        y: -(size / 2 - padding - dotSize / 2))

            Circle()
                .fill(OddsTheme.downRed)
                .frame(width: dotSize, height: dotSize)
                .offset(x: size / 2 - padding - dotSize / 2,
                        y: -(size / 2 - padding - dotSize / 2))

            Circle()
                .fill(OddsTheme.downRed)
                .frame(width: dotSize, height: dotSize)
                .offset(x: -(size / 2 - padding - dotSize / 2),
                        y: size / 2 - padding - dotSize / 2)

            Circle()
                .fill(OddsTheme.lime)
                .frame(width: dotSize, height: dotSize)
                .offset(x: size / 2 - padding - dotSize / 2,
                        y: size / 2 - padding - dotSize / 2)
        }
        .frame(width: size, height: size)
    }
}

struct HeaderIconButton: View {
    let icon: String
    let isActive: Bool

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(isActive ? OddsTheme.text1 : OddsTheme.text3)
            .frame(width: 28, height: 28)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isActive ? Color.white.opacity(0.05) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isActive ? Color.white.opacity(0.15) : OddsTheme.border, lineWidth: 1)
            )
    }
}
