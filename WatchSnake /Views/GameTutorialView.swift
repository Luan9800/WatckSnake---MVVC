import SwiftUI
import WatchKit

struct GameTutorialView: View {
    @State private var pulse = false
    @State private var navigateToGameMode = false
    
    @Binding var isShowingTutorial: Bool
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: geometry.size.height * 0.010) {
                        HStack(spacing: 4) {
                            Text("Como")
                                .foregroundColor(.green)
                                .bold()
                                .font(.system(size: geometry.size.width * 0.12, weight: .heavy, design: .monospaced))
                                .shadow(color: .green.opacity(0.5), radius: 0, x: 1.5, y: 1.5)

                            Text("Jogar")
                                .foregroundColor(.red)
                                .bold()
                                .font(.system(size: geometry.size.width * 0.12, weight: .heavy, design: .monospaced))
                                .shadow(color: .red.opacity(0.5), radius: 0, x: 1.5, y: 1.5)

                            Text("🐍")
                                .font(.system(size: geometry.size.width * 0.12))
                        }                        .font(.system(size: geometry.size.width * 0.12))
                        .padding(.top, geometry.size.height * 0.02)
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.03) {
                            Text("🎯 **Objetivo**")
                                .font(.system(size: geometry.size.width * 0.08))
                                .bold()
                            Text("Sobreviva o máximo possível, sem tocar nas paredes ou em si mesmo.")
                                .font(.system(size: geometry.size.width * 0.07))
                            
                            Text("🎮 **Controles**")
                                .font(.system(size: geometry.size.width * 0.08))
                                .bold()
                            Text("Toque na tela para mudar de direção.")
                                .font(.system(size: geometry.size.width * 0.07))
                            
                            Spacer()
                            Text("🔥 **Elementos:**")
                                .font(.system(size: geometry.size.width * 0.08))
                                .bold()
                        }
                        .multilineTextAlignment(.center)
                        
                        VStack(alignment: .leading, spacing: geometry.size.height * 0.008) {
                            HStack {
                                Image(systemName: "square.fill")
                                    .foregroundColor(.red)
                                    .imageScale(.small)
                                Text("Comida (+10 pontos)")
                                    .font(.system(size: geometry.size.width * 0.07))
                            }
                            
                            HStack {
                                Image(systemName: "square.fill")
                                    .foregroundColor(.yellow)
                                    .imageScale(.small)
                                Text("Estrela (Ganha +2")
                                    .font(.system(size: geometry.size.width * 0.07))
                            }
                            
                            HStack {
                                Image(systemName: "square.fill")
                                    .foregroundColor(.gray)
                                    .imageScale(.small)
                                Text("Bomba (Perde pedaço)")
                                    .font(.system(size: geometry.size.width * 0.07))
                            }
                            HStack {
                                Image(systemName: "square.fill")
                                    .foregroundColor(.white)
                                    .imageScale(.small)
                                Text("Parede (Perde a Partida)")
                                    .font(.system(size: geometry.size.width * 0.07))
                            }
                            HStack {
                                Image(systemName: "square.fill")
                                    .foregroundColor(.purple)
                                    .imageScale(.small)
                                Text("Comida roxa (Aumenta o tamanho da cobra e atravessa paredes por tempo limitado)")
                                    .font(.system(size: geometry.size.width * 0.07))
                            }
                            HStack {
                                Image(systemName: "square.fill")
                                    .foregroundColor(.orange)
                                    .imageScale(.small)
                                Text(" Comida Laranja (Desacelerar a cobrinha durante o jogo)")
                                    .font(.system(size: geometry.size.width * 0.07))
                            }
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.red)
                                    .imageScale(.small)
                                Text("Fechar tela de Pontuação (Sair)")
                                    .font(.system(size: geometry.size.width * 0.07))
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                        
                        Spacer()
                        
                        // 🔥 Botão ajustável para qualquer tela
                        Button(action: {
                            navigateToGameMode = true
                        }) {
                            Text("🐍")
                                .font(.system(size: geometry.size.width * 0.15))
                                .scaleEffect(pulse ? 1.4 : 1.0)
                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)
                                .padding(geometry.size.height * 0.015)
                                .frame(maxWidth: geometry.size.width * 0.8)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(geometry.size.width * 0.1)
                                .onAppear {
                                    pulse = true
                                }
                        }
                        .padding(.bottom, geometry.size.height * 0.03)
                        .buttonStyle(.plain)
                        .navigationDestination(isPresented: $navigateToGameMode) {
                            EnterPlayerNameView()
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                }
            }
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .automatic)
        }
    }
}

#Preview {
    GameTutorialView(isShowingTutorial: .constant(true))
}
