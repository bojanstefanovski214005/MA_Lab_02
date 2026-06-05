//
//  ContentView.swift
//  MA_Lab_03
//
//  Created by Bojan Stefanovski on 09/05/2026.
//
//
import SwiftUI
import Combine
import PhotosUI
import MapKit
import CoreLocation


struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    let description: String
}


class MenuViewModel: ObservableObject {
    
    @Published var comments: [UUID: [String]] = [:]
    
    @Published var randomFact: String = "Се вчитува..."
    
    func addComment(_ comment: String, for item: MenuItem) {
        if comments[item.id] != nil {
            comments[item.id]?.append(comment)
        } else {
            comments[item.id] = [comment]
        }
    }
    
    func fetchMeal() {
        
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/random.php") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(MealResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.randomFact = decoded.meals.first?.strMeal ?? "No meal found"
                }
                
            } catch {
                print(error.localizedDescription)
            }
            
        }.resume()
    }
}

struct MealResponse: Codable {
    let meals: [Meal]
}

struct Meal: Codable {
    let strMeal: String
}
let drinks: [MenuItem] = [
    MenuItem(
        title: "Кафе",
        subtitle: "Топол пијалок",
        imageName: "cup.and.saucer.fill",
        description: "Свежо подготвено кафе."
    ),
    
    MenuItem(
        title: "Сок",
        subtitle: "Природен пијалок",
        imageName: "takeoutbag.and.cup.and.straw.fill",
        description: "Свеж овошен сок."
    )
]

let foods: [MenuItem] = [
    MenuItem(
        title: "Пица",
        subtitle: "Италијанска храна",
        imageName: "fork.knife",
        description: "Вкусна италијанска пица."
    ),
    
    MenuItem(
        title: "Салата",
        subtitle: "Здрава храна",
        imageName: "leaf.fill",
        description: "Свежа и здрава салата."
    )
]

struct MenuRow: View {
    
    let item: MenuItem
    
    var body: some View {
        
        HStack(spacing: 15) {
            
            Image(systemName: item.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .padding()
                .background(Color.green.opacity(0.3))
                .cornerRadius(12)
            
            VStack(alignment: .leading) {
                
                Text(item.title)
                    .font(.headline)
                
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            picker.dismiss(animated: true)
        }
    }
}

struct DetailView: View {
    
    let item: MenuItem
    
    @EnvironmentObject var viewModel: MenuViewModel
    
    @State private var commentText = ""
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing: 20) {
                
                Image(systemName: item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding()
                
                Text(item.title)
                    .font(.largeTitle)
                    .bold()
                
                Text(item.description)
                    .font(.body)
                    .padding(.horizontal)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("Предлог оброк од API:")
                        .font(.headline)
                    
                    Text(viewModel.randomFact)
                        .foregroundColor(.green.opacity(1))
                }
                .padding()
                
                Divider()
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("Коментари")
                        .font(.headline)
                    
                    TextField("Внеси коментар...", text: $commentText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Додади коментар") {
                        
                        if !commentText.isEmpty {
                            viewModel.addComment(commentText, for: item)
                            commentText = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if let comments = viewModel.comments[item.id] {
                        
                        ForEach(comments, id: \.self) { comment in
                            
                            Text("• \(comment)")
                                .padding(.vertical, 2)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(item.title)
        .onAppear {
            viewModel.fetchMeal()
        }
    }
}


struct DrinksView: View {
    
    var body: some View {
        
        NavigationView {
            
            List(drinks) { drink in
                
                NavigationLink(destination: DetailView(item: drink)) {
                    MenuRow(item: drink)
                }
            }
            .navigationTitle("Пијалоци")
        }
    }
}


struct FoodView: View {
    
    var body: some View {
        
        NavigationView {
            
            List(foods) { food in
                
                NavigationLink(destination: DetailView(item: food)) {
                    MenuRow(item: food)
                }
            }
            .navigationTitle("Храна")
        }
    }
}

struct RestaurantLocationView: View {
    
    let restaurantCoordinate = CLLocationCoordinate2D(
        latitude: 41.0316,
        longitude: 21.3347
    )
    
    var body: some View {
        
        Map(position: .constant(
            .region(
                MKCoordinateRegion(
                    center: restaurantCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        )) {
            Marker("Замислен ресторан", coordinate: restaurantCoordinate)
        }
        .navigationTitle("Локација")
    }
}


struct ContentView: View {
    
    @StateObject var viewModel = MenuViewModel()
    
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        
        TabView {
            
            DrinksView()
                .tabItem {
                    Image(systemName: "cup.and.saucer.fill")
                    Text("Пијалоци")
                }
            
            FoodView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Храна")
                }
            
            NavigationView {
                VStack(spacing: 20) {
                    
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .cornerRadius(12)
                            .padding()
                    } else {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                    }
                    
                    Button("Сликај фотографија") {
                        sourceType = .camera
                        showImagePicker = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Прикачи фотографија") {
                        sourceType = .photoLibrary
                        showImagePicker = true
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                }
                .navigationTitle("Фотографии")
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
                }
            }
            .tabItem {
                Image(systemName: "camera.fill")
                Text("Камера")
            }
            
            NavigationView {
                RestaurantLocationView()
            }
            .tabItem {
                Image(systemName: "mappin.and.ellipse")
                Text("Локација")
            }
        }
        .environmentObject(viewModel)
    }
}


#Preview {
    ContentView()
}
