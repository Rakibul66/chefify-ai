import SwiftUI

struct ResultScreen: View {
    let images: [ImageData]
    let columns = [GridItem(.flexible()), GridItem(.flexible())] // Two columns for grid layout
    let totalRecipes: Int // Total recipes count

    @Environment(\.presentationMode) var presentationMode // To handle back navigation

    var body: some View {
        VStack(spacing: 16) {
            // Custom App Bar
            ZStack {
                Color.orange
                    .ignoresSafeArea(edges: .top)

                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // Back navigation
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding()
                    }

                    Spacer()

                    Text("Result Screen")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Spacer()
                }
                .padding(.horizontal)
                .frame(height: 56) // App bar height
            }
            .frame(height: 56)

            // Total Recipes Card
            VStack {
                Text("Total Recipes")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("\(totalRecipes) recipes with your ingredients")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)

            // Grid Layout for Images
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(images) { image in
                        Button(action: {
                            openURL(url: image.source) // Open recipe source URL
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                // Image covering 35% of the card
                                AsyncImage(url: URL(string: image.imageUrl)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(height: 70) // 35% of 200px
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 70)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 70)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(height: 70) // 35% of card height

                                // Title
                                Text(image.title)
                                    .font(.headline)
                                    .lineLimit(2)

                                // Source
                                Text("Source: \(image.source)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(height: 200) // Card height
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.systemGray6)) // Background color
    }

    private func openURL(url: String) {
        var formattedURL = url
        // Check if the URL doesn't start with http or https, and prepend https://
        if !formattedURL.lowercased().hasPrefix("http://") && !formattedURL.lowercased().hasPrefix("https://") {
            formattedURL = "https://\(formattedURL)"
        }

        guard let validURL = URL(string: formattedURL), UIApplication.shared.canOpenURL(validURL) else {
            print("Invalid URL: \(url)")
            return
        }

        UIApplication.shared.open(validURL, options: [:], completionHandler: nil)
    }



}
