import SwiftUI

// MARK: - Section View
struct SectionView: View {
    let title: String
    let options: [String]
    @Binding var selectedOption: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                    }) {
                        Text(option)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedOption == option ? Color.orange : Color.gray, lineWidth: selectedOption == option ? 2 : 1)
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom)
    }
}
struct ContentView: View {
    @StateObject private var viewModel = ImageSearchViewModel()
    @State private var selectedCuisine: String? = nil
    @State private var selectedCookingTime: String? = nil
    @State private var selectedCookingFor: String? = nil
    @State private var selectedComplexity: String? = nil
    @State private var selectedDiet: String? = nil
    
    @State private var searchQuery: String = ""
    @State private var isSearching: Bool = false
    @State private var showLoadingScreen: Bool = false
    @State private var showResultScreen: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // AppBar
                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.orange)
                            .frame(height: 180)
                            .shadow(radius: 5)

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "chef.hat.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("Welcome to Chefify AI")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal)

                            Text("We will help you to find the best recipe for you")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal)

                    // Select Cuisine
                    SectionView(title: "Select Cuisine", options: ["Chinese", "Indian", "French", "Italian", "Japanese", "Spanish", "Greek", "Mexican", "UK", "Bangladesh"], selectedOption: $selectedCuisine)

                    // Cooking Time
                    SectionView(title: "Cooking Time", options: ["Less than 30 min", "Less than 1 hour", "1 to 2 hours", "Doesn't matter"], selectedOption: $selectedCookingTime)

                    // Who are you cooking for
                    SectionView(title: "Who are you cooking for", options: ["Myself", "Family", "Date", "Party", "Children"], selectedOption: $selectedCookingFor)

                    // Complexity Level
                    SectionView(title: "Complexity Level", options: ["Basic", "Medium", "Complex"], selectedOption: $selectedComplexity)

                    // Diet
                    SectionView(title: "Diet", options: ["Omnivore", "Vegetarian", "No Veg"], selectedOption: $selectedDiet)

                    // Navigation to Loading Screen
                    NavigationLink(
                        destination: LoadingScreen(onComplete: {
                            showResultScreen = true
                        }),
                        isActive: $showLoadingScreen
                    ) {
                        Button(action: {
                            prepareQuery()
                            viewModel.fetchImages(for: searchQuery)
                            showLoadingScreen = true
                        }) {
                            Text("Prepare Recipe")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Capsule().fill(Color.orange))
                                .padding(.horizontal)
                                .shadow(radius: 5)
                        }
                    }

                    // Navigation to Result Screen
                    NavigationLink(
                        destination: ResultScreen(images: viewModel.images, totalRecipes: viewModel.images.count),
                        isActive: $showResultScreen
                    ) {
                        EmptyView()
                    }
                }
            }
            .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
        }
    }

    // Combine selected options into a search query
    private func prepareQuery() {
        var queryParts: [String] = []
        
        if let cuisine = selectedCuisine {
            queryParts.append("Cuisine: \(cuisine)")
        }
        if let cookingTime = selectedCookingTime {
            queryParts.append("Cooking Time: \(cookingTime)")
        }
        if let cookingFor = selectedCookingFor {
            queryParts.append("Cooking For: \(cookingFor)")
        }
        if let complexity = selectedComplexity {
            queryParts.append("Complexity: \(complexity)")
        }
        if let diet = selectedDiet {
            queryParts.append("Diet: \(diet)")
        }
        
        searchQuery = queryParts.joined(separator: ", ")
        isSearching = true
        print("Query: \(searchQuery)")
    }
}
// MARK: - Loading Screen
struct LoadingScreen: View {
    var onComplete: () -> Void

    var body: some View {
        VStack {
            Spacer()

            Image(systemName: "leaf.arrow.circlepath")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(360))
                .animation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false),
                    value: UUID()
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        onComplete()
                    }
                }

            Text("Sit tight while I prepare your recipe. It won't take time.")
                .multilineTextAlignment(.center)
                .padding()

            Text("Thanks for waiting.")
                .font(.footnote)
                .foregroundColor(.gray)

            Spacer()
        }
        .padding()
    }
}
