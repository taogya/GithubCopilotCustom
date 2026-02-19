#!/usr/bin/env bash
# ============================================================
#  render-diagrams.sh
#  Mermaid ダイアグラムを Kroki.io 経由で SVG にレンダリング
#  白背景・ライトモード統一（ダーク/ライト分割しない）
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DIAGRAM_DIR="$PROJECT_ROOT/docs/resources/diagram"
IMG_DIR="$PROJECT_ROOT/docs/resources/images"
KROKI_URL="https://kroki.io/mermaid/svg"

mkdir -p "$IMG_DIR"

# ──────────────────────────────────────────────
# テーマ定義（白背景・ライトモード統一）
# ──────────────────────────────────────────────

CLASSDEFS='
    classDef blue fill:#DBEAFE,stroke:#3B82F6,stroke-width:2px,color:#1E40AF,rx:8,ry:8
    classDef green fill:#D1FAE5,stroke:#10B981,stroke-width:2px,color:#065F46,rx:8,ry:8
    classDef amber fill:#FEF3C7,stroke:#F59E0B,stroke-width:2px,color:#92400E,rx:8,ry:8
    classDef purple fill:#EDE9FE,stroke:#8B5CF6,stroke-width:2px,color:#5B21B6,rx:8,ry:8
    classDef pink fill:#FCE7F3,stroke:#EC4899,stroke-width:2px,color:#9D174D,rx:8,ry:8
    classDef neutral fill:#F1F5F9,stroke:#94A3B8,stroke-width:2px,color:#334155,rx:8,ry:8
'

GRAPH_INIT='%%{init: {"theme": "base", "themeVariables": {"background": "#FFFFFF", "primaryColor": "#DBEAFE", "lineColor": "#475569", "textColor": "#1E293B", "fontSize": "15px", "edgeLabelBackground": "#FAFAF8", "clusterBkg": "#F8FAFC", "clusterBorder": "#CBD5E1"}}}%%'

SEQ_INIT='%%{init: {"theme": "base", "themeVariables": {"background": "#FFFFFF", "fontSize": "15px", "actorBkg": "#DBEAFE", "actorBorder": "#3B82F6", "actorTextColor": "#1E40AF", "actorLineColor": "#475569", "signalColor": "#475569", "signalTextColor": "#1E293B", "labelBoxBkgColor": "#F1F5F9", "labelBoxBorderColor": "#94A3B8", "labelTextColor": "#1E293B", "loopTextColor": "#1E293B", "noteBkgColor": "#FEF3C7", "noteTextColor": "#92400E", "noteBorderColor": "#F59E0B", "activationBkgColor": "#EDE9FE", "activationBorderColor": "#8B5CF6", "sequenceNumberColor": "#FFFFFF"}}}%%'

# ──────────────────────────────────────────────
# レンダリング関数
# ──────────────────────────────────────────────

render_diagram() {
    local src_file="$1"
    local out_file="$2"
    local init_line="$3"
    local classdefs="$4"

    local first_line
    first_line=$(head -1 "$src_file")

    local content
    if [[ "$first_line" == sequenceDiagram* ]]; then
        content="${init_line}
$(cat "$src_file")"
    else
        local rest
        rest=$(tail -n +2 "$src_file")
        content="${init_line}
${first_line}
${classdefs}
${rest}"
    fi

    local http_code
    http_code=$(curl -s -w "\n%{http_code}" -X POST "$KROKI_URL" \
        -H "Content-Type: text/plain" \
        --data-binary "$content" \
        -o "$out_file")

    http_code=$(echo "$http_code" | tail -1)

    if [[ "$http_code" == "200" ]]; then
        # SVG に背景色を注入（透過防止）
        perl -i -pe 's/(<svg[^>]*>)/$1<rect width="100%" height="100%" fill="#FAFAF8"\/>/' "$out_file"
        echo "  ✅ $(basename "$out_file")"
    else
        echo "  ❌ $(basename "$out_file") (HTTP $http_code)"
        echo "     Content preview: $(echo "$content" | head -3)"
    fi
}

# ──────────────────────────────────────────────
# メイン処理
# ──────────────────────────────────────────────

echo "🎨 Rendering diagrams via Kroki.io (white background) ..."
echo ""

for src in "$DIAGRAM_DIR"/*.mmd; do
    name=$(basename "$src" .mmd)
    echo "📊 $name"

    first_line=$(head -1 "$src")

    if [[ "$first_line" == sequenceDiagram* ]]; then
        render_diagram "$src" "$IMG_DIR/${name}.svg" "$SEQ_INIT" ""
    else
        render_diagram "$src" "$IMG_DIR/${name}.svg" "$GRAPH_INIT" "$CLASSDEFS"
    fi
done

echo ""
echo "✨ Done! Output: $IMG_DIR/"
echo ""
echo "Generated files:"
ls -lh "$IMG_DIR"/*.svg 2>/dev/null | awk '{print "  " $5 " " $NF}'
