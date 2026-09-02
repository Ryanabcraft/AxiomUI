# Axiom Design System

Axiom segue a metáfora de uma **control surface**: chrome compacto, navegação instrumental e conteúdo organizado como um inspector. A interface deve parecer ferramenta, não decoração sobre o jogo.

## Princípios

1. **Hierarquia espacial:** canvas escuro, surfaces progressivamente mais claras e uma borda para separar planos.
2. **Cor com função:** violeta indica seleção; verde, amarelo e vermelho comunicam estado.
3. **Densidade legível:** labels de 9–13 px, ritmo de 8 px e agrupamento por panels/sections.
4. **Movimento curto:** feedback entre 120–340 ms, sem atrasar a ação.
5. **Geometria preservada:** drag, resize, minimize, maximize e visibility mantêm o contexto do usuário.
6. **Responsividade estrutural:** reduzir rail e gaps antes de sacrificar conteúdo.

## Anatomia da Window

| Elemento | Desktop | Tablet | Mobile |
| --- | --- | --- | --- |
| Sidebar | 88 px | 72 px | 56 px |
| Tab | 56×52 | 52×52 | 48×48 |
| Margin segura | 24 px | 16 px | 12 px |
| Header lógico | 58 px | 58 px | 58 px |

O tamanho de referência é `500×475`. O engine calcula uma escala que cabe no viewport e aplica o multiplicador do usuário, limitado entre `0.75` e `1.25`. Column groups empilham em Mobile portrait ou com área de conteúdo menor que 340 px.

## Tokens semânticos

| Token | Papel |
| --- | --- |
| `Background` | Base da Window |
| `Surface` | Chrome, sidebar e surfaces principais |
| `SurfaceAlt` | Rows e panels |
| `SurfaceHover` | Hover/foco transitório |
| `Stroke` | Separadores e contornos |
| `Text` | Conteúdo primário |
| `TextMuted` | Metadados e ícones inativos |
| `Primary` | Seleção e ação principal |
| `Secondary` | Gradientes e contraste de accent |
| `Success` | Confirmação |
| `Warning` | Atenção |
| `Danger` | Ação destrutiva |
| `Radius` | Raio padrão dos componentes |
| `Transparency` | Opacidade de rows |
| `AcrylicTransparency` | Opacidade da Window |

Use tokens em vez de inserir paletas diretamente nos componentes. `Theme:Bind` atualiza propriedades vinculadas quando o tema muda; propriedades locais não registradas não são retroativas.

## Motion

- Hover e feedback: 120–160 ms.
- Tabs e popups: aproximadamente 160–220 ms.
- Window transitions: 220–340 ms.
- Easing principal: quintic-out para entrada e mudança de geometria.
- A posição visual deve começar no estado atual; nunca use um valor absoluto de outro sistema de coordenadas como origem de drag.

## Iconografia

Axiom usa exclusivamente a família Lucide linear para o registry padrão. Ícones devem manter stroke simples, leitura em 22 px e cor semântica (`TextMuted` inativo, branco ativo). Aliases pertencem ao lookup e nunca duplicam assets oficiais. Consulte [ICONS.md](ICONS.md).

## Acrylic

O tratamento é inspirado em acrylic: surface translúcida, gradiente local, borda e profundidade. Axiom não aplica blur à cena, não cria `BlurEffect` e não altera `Lighting` ou câmera.

## Tema customizado

```lua
local Neon=Axiom:CreateTheme({
    Name="Neon",
    Primary=Color3.fromRGB(0,220,255),
    Secondary=Color3.fromRGB(174,72,255),
    Radius=UDim.new(0,12),
    AcrylicTransparency=0.18,
})

Axiom:SetTheme(Neon)
```

## Marca

O símbolo Axiom é um “A” geométrico atravessado por um eixo luminoso. O eixo representa uma regra estável transformada em sistema. Use a marca com espaço livre, wordmark uppercase e tracking amplo; não substitua por emoji ou glyph genérico.
