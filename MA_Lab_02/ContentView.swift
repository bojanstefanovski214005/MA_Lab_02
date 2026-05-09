//
//  ContentView.swift
//  MA_Lab_02
//
//  Created by Bojan Stefanovski on 09/05/2026.
//
//
import SwiftUI


struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
}


let drinks: [MenuItem] = [
    MenuItem(title: "Кафе", subtitle: "Топол пијалок", imageName: "cup.and.saucer.fill"),
    MenuItem(title: "Сок од портокал", subtitle: "Природен сок", imageName: "takeoutbag.and.cup.and.straw.fill"),
    MenuItem(title: "Кока Кола", subtitle: "Газиран пијалок", imageName: "sparkles")
]

let foods: [MenuItem] = [
    MenuItem(title: "Пица", subtitle: "Италијанска храна", imageName: "fork.knife"),
    MenuItem(title: "Бургер", subtitle: "Брза храна", imageName: "takeoutbag.and.cup.and.straw.fill"),
    MenuItem(title: "Салата", subtitle: "Здрава храна", imageName: "leaf.fill")
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
            
            VStack(alignment: .leading, spacing: 5) {
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


struct DrinksView: View {
    var body: some View {
        NavigationView {
            List(drinks) { drink in
                MenuRow(item: drink)
            }
            .navigationTitle("Пијалоци")
        }
    }
}


struct FoodView: View {
    var body: some View {
        NavigationView {
            List(foods) { food in
                MenuRow(item: food)
            }
            .navigationTitle("Храна")
        }
    }
}


struct ContentView: View {
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
        }
    }
}


#Preview {
    ContentView()
}
