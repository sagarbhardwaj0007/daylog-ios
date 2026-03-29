import SwiftUI

struct ImageGridView: View {
    let images: [UIImage]
    var onRemove: ((Int) -> Void)? = nil

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(images.indices, id: \.self) { index in
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: images[index])
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 100, minHeight: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    if let onRemove {
                        Button {
                            withAnimation(.spring(duration: 0.25)) {
                                onRemove(index)
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .background(Color.black.opacity(0.5), in: Circle())
                        }
                        .padding(6)
                    }
                }
            }
        }
    }
}
