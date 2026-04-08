import SwiftUI

struct SoundscapeCardData: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let duration: String
    let isNew: Bool
    let cardColor: Color
}

let libraryCards: [SoundscapeCardData] = [
    SoundscapeCardData(title: "Deep Sleep", author: "Jenny", duration: "15 min",
                       isNew: false, cardColor: Color(hex: "#1a1060")),
    SoundscapeCardData(title: "Magical City", author: "Regina", duration: "17 min",
                       isNew: true, cardColor: Color(hex: "#0d1f3c")),
    SoundscapeCardData(title: "You Are Not Alone", author: "Kathryn", duration: "10 min",
                       isNew: false, cardColor: Color(hex: "#1a0d2e")),
    SoundscapeCardData(title: "Planet Of Crystals", author: "Irma", duration: "25 min",
                       isNew: false, cardColor: Color(hex: "#0a1628")),
]

private let filterChips = ["All", "Meditation", "Soundscapes", "Nature", "Focus"]

struct AvatarItem: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

let libraryAvatars: [AvatarItem] = [
    AvatarItem(name: "Jenny", color: Color(red: 0.5, green: 0.3, blue: 0.9)),
    AvatarItem(name: "Jane", color: Color(red: 0.2, green: 0.6, blue: 0.9)),
    AvatarItem(name: "Regina", color: Color(red: 0.9, green: 0.4, blue: 0.3)),
    AvatarItem(name: "Bessie", color: Color(red: 0.3, green: 0.8, blue: 0.5)),
    AvatarItem(name: "Lily", color: Color(red: 1.0, green: 0.6, blue: 0.2)),
]

struct LibraryTabView: View {
    @State private var selectedFilter = "All"
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HeroHeaderView(height: 240)

                    VStack(alignment: .leading, spacing: 20) {
                        filterRow
                            .padding(.top, 16)

                        avatarRow

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(libraryCards) { card in
                                LibraryCardView(card: card)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .background(SlipieColors.background.ignoresSafeArea())
            .ignoresSafeArea(edges: .top)
        }
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filterChips, id: \.self) { chip in
                    FilterChipView(
                        title: chip,
                        isSelected: chip == selectedFilter
                    ) {
                        selectedFilter = chip
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, -16)
    }

    private var avatarRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(libraryAvatars) { avatar in
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(avatar.color.opacity(0.25))
                                .frame(width: 48, height: 48)
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(avatar.color)
                        }
                        Text(avatar.name)
                            .font(SlipieTypography.caption2())
                            .foregroundStyle(SlipieColors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, -16)
    }
}

struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(SlipieTypography.caption())
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? SlipieColors.background : SlipieColors.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        Capsule().fill(Color.white)
                    } else {
                        Capsule().fill(Color.clear)
                            .overlay(Capsule().stroke(SlipieColors.textSecondary.opacity(0.3), lineWidth: 1))
                    }
                }
                .frame(height: 32)
        }
        .buttonStyle(.plain)
    }
}

struct LibraryCardView: View {
    let card: SoundscapeCardData

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [card.cardColor, card.cardColor.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 160)

            VStack(alignment: .leading) {
                HStack {
                    durationBadge
                    Spacer()
                    statusBadge
                }

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    Text(card.title)
                        .font(SlipieTypography.headline())
                        .foregroundStyle(SlipieColors.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(card.author)
                        .font(SlipieTypography.caption())
                        .foregroundStyle(SlipieColors.textSecondary)
                }
            }
            .padding(12)
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var durationBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(.system(size: 9))
            Text(card.duration)
                .font(SlipieTypography.caption2())
        }
        .foregroundStyle(SlipieColors.textPrimary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.4))
        .clipShape(Capsule())
    }

    private var statusBadge: some View {
        Group {
            if card.isNew {
                Text("New")
                    .font(SlipieTypography.caption2())
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#FF6B35"))
                    .clipShape(Capsule())
            } else {
                Text("Free")
                    .font(SlipieTypography.caption2())
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(SlipieColors.accentEnd)
                    .clipShape(Capsule())
            }
        }
    }
}
