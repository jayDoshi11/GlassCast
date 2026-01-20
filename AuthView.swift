//
//  AuthView.swift
//  Glasscast
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var didTap = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: colorScheme == .dark ? [.black, .indigo, .blue] : [.blue, .purple, .pink],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .opacity(0.22)
                
                VStack(spacing: 18) {
                    VStack(spacing: 10) {
                        Image(systemName: "cloud.sun.fill")
                            .font(.system(size: 64))
                            .symbolRenderingMode(.multicolor)
                            .symbolEffect(reduceMotion ? .none : .variableColor.iterative, value: didTap)
                            .scaleEffect(didTap ? 1.04 : 1.0)
                            .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.65), value: didTap)
                            .onTapGesture { didTap.toggle() }
                        
                        Text("Welcome to Glasscast")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.primary)
                        
                        Text("Sign in to sync favorites across devices.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 320)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 14) {
                        TextField("Email", text: $viewModel.email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled(true)
                            .textFieldStyle(.roundedBorder)
                        
                        SecureField("Password", text: $viewModel.password)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal, 16)
                    
                    VStack(spacing: 12) {
                        Button {
                            viewModel.signIn()
                        } label: {
                            Label("Sign In", systemImage: "arrow.right.circle.fill")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.isLoading)
                        .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.isLoading)
                        
                        Button {
                            viewModel.signUp()
                        } label: {
                            Text("Create Account")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.bordered)
                        .disabled(viewModel.isLoading)
                    }
                    .padding(.horizontal, 16)
                    
                    if let msg = viewModel.errorMessage, !msg.isEmpty {
                        Text(msg)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.85), value: msg)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 24)
                .background(
                    reduceTransparency ? Color.black.opacity(0.10) : .regularMaterial,
                    in: RoundedRectangle(cornerRadius: 28, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.12 : 0.10), lineWidth: 1)
                )
                .padding()
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.22 : 0.12), radius: 18, y: 10)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(AuthViewModel())
    }
}

