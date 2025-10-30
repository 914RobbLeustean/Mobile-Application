//
//  GlassCard.swift
//  HabitFlow
//
//  Reusable glassmorphism component inspired by iOS 26 Liquid Glass
//

import SwiftUI

/// A card with translucent glass-like appearance
/// Inspired by iOS 26's Liquid Glass design language
struct GlassCard<Content: View>: View {
    let content: Content
    var backgroundColor: Color
    var cornerRadius: CGFloat
    var opacity: Double
    
    init(
        backgroundColor: Color = .white,
        cornerRadius: CGFloat = 20,
        opacity: Double = 0.1,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.opacity = opacity
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                ZStack {
                    // Translucent background layer
                    backgroundColor
                        .opacity(opacity)
                    
                    // Blur effect for glassmorphism
                    Rectangle()
                        .fill(.ultraThinMaterial)
                }
            )
            .cornerRadius(cornerRadius)
            .overlay(
                // Subtle border for depth
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.3),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

/// A vibrant card with colored glass effect
struct ColoredGlassCard<Content: View>: View {
    let content: Content
    let color: Color
    
    init(
        color: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                ZStack {
                    // Gradient background
                    LinearGradient(
                        colors: [
                            color.opacity(0.3),
                            color.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Glass blur effect
                    Rectangle()
                        .fill(.ultraThinMaterial)
                }
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color.opacity(0.3), lineWidth: 1.5)
            )
            .shadow(color: color.opacity(0.2), radius: 15, x: 0, y: 8)
    }
}

/// Icon badge with glass effect
struct GlassIconBadge: View {
    let icon: String
    let color: Color
    let size: CGFloat
    
    init(icon: String, color: Color, size: CGFloat = 50) {
        self.icon = icon
        self.color = color
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
            
            Circle()
                .fill(.ultraThinMaterial)
            
            Image(systemName: icon)
                .font(.system(size: size * 0.5))
                .foregroundStyle(color)
        }
        .frame(width: size, height: size)
        .overlay(
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 1.5)
        )
        .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview

#Preview("Glass Cards") {
    ZStack {
        // Background gradient
        LinearGradient(
            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 20) {
            // Standard glass card
            GlassCard {
                VStack(alignment: .leading) {
                    Text("Standard Glass Card")
                        .font(.headline)
                    Text("Translucent with blur effect")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Colored glass card
            ColoredGlassCard(color: .blue) {
                VStack(alignment: .leading) {
                    Text("Colored Glass Card")
                        .font(.headline)
                    Text("Vibrant with gradient")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Icon badges
            HStack(spacing: 20) {
                GlassIconBadge(icon: "heart.fill", color: .red)
                GlassIconBadge(icon: "star.fill", color: .yellow)
                GlassIconBadge(icon: "leaf.fill", color: .green)
            }
        }
        .padding()
    }
}
