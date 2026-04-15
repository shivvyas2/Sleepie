import SwiftUI

struct LibraryTabView: View {
    @StateObject private var viewModel = LibraryViewModel()
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
                        isSelected: chip == viewModel.selectedFilter
                    ) {
                        viewModel.selectedFilter = chip
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
                            .font(SlipieTypography.caption2)
                            .foregroundStyle(SlipieColors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, -16)
    }
}
