<!--
SYNC HEADER — この仕様書は派生ドキュメントです
原典 (single source of truth): apps/ThumbnailThumb/docs/api-design.md §4「データモデル」+ 付録 B「利用可能プリセット」
実装の正: ElementRequestWireDTO (Sources/Services/API/DTOs/ElementDTO.swift) / CanvasMutationHandler.swift
方針: 手書き派生・手動同期。記述が原典/実装と食い違う場合は原典・実装を正とする。
      要素フィールド・色・preset を変更したら、原典 api-design.md §4 を先に直してから本書へ反映する。
最終同期日: 2026-06-17 / 対象 schemaVersion: 1
-->

# ThumbnailThumb 取り込みフォーマット仕様書

> この仕様書は ThumbnailThumb の内部設計書から手動で派生した「取り込み専用サブセット」です。記述が実アプリの挙動と食い違う場合は、アプリの挙動が正です。

## 1. これは何か

ChatGPT などの LLM に「ThumbnailThumb に取り込める JSON を書いて」と依頼し、出力された JSON テキストを ThumbnailThumb の入力フォームに貼り付けると、**現在のキャンバスに複数の要素（テキスト・図形・モザイク）が一括で追加**されます。

- **非破壊マージ**: 既存の要素は消えません。貼り付けた要素が「追加」されます。
- **API モード不要**: ローカル API サーバーを起動する必要はありません。クリップボード経由のテキスト貼り付けだけで完結します。
- **対象要素**: テキスト（text）・図形（shape）・モザイク（effectOverlay）。画像は後述の制限あり。

---

## 2. トップレベルの形（封筒）

```json
{
  "format": "thumbnailthumb.import",
  "schemaVersion": 1,
  "canvas": { "preset": "youtube" },
  "elements": [
    { "type": "text", "text": "...", "...": "..." }
  ]
}
```

| フィールド | 型 | 必須 | 説明 |
|-----------|-----|:----:|------|
| `format` | string | - | 固定値 `"thumbnailthumb.import"`。付ける場合は完全一致が必要 |
| `schemaVersion` | number | - | 現在は `1`。省略可 |
| `canvas` | object | - | キャンバス指定（§3）。**省略すると現在開いているキャンバスにマージ**される |
| `elements` | array | ✅ | 追加する要素の配列（§5〜§7） |

**受理される 3 つの形**（どれでも貼り付け可能）:

```json
// 1. 完全形（推奨）
{ "format": "thumbnailthumb.import", "schemaVersion": 1, "canvas": { "preset": "youtube" }, "elements": [ ... ] }

// 2. 封筒だけ（canvas 省略 = 現キャンバスへ）
{ "elements": [ ... ] }

// 3. 素の配列
[ { "type": "text", "text": "..." } ]
```

---

## 3. canvas 指定

`canvas.preset` に下記のトークンを指定します。未知のトークンは拒否されます。

| preset トークン | サイズ (px) | 用途 |
|----------------|------------|------|
| `youtube` | 1280 × 720 | YouTube サムネイル |
| `mirrativ` | 1280 × 720 | Mirrativ |
| `instagram_square` | 1080 × 1080 | Instagram 正方形 |
| `instagram_story` | 1080 × 1920 | Instagram ストーリー |
| `tiktok` | 1080 × 1920 | TikTok |
| `twitch` | 1920 × 1080 | Twitch |
| `x` （= `twitter`） | 1200 × 675 | X / Twitter |
| `facebook` | 1200 × 630 | Facebook |
| `square_1024` | 1024 × 1024 | 汎用正方形 |
| `portrait_hd` | 1080 × 1920 | 縦長 HD |
| `portrait_xl` | 1290 × 2796 | 縦長 XL |
| `landscape_full_hd` | 1920 × 1080 | 横長 Full HD |
| `landscape_4k` | 3840 × 2160 | 横長 4K |

> 任意ピクセルサイズ・背景色の指定は現バージョンでは未対応です。背景は現在のキャンバスのものが使われます。

---

## 4. 値の表現（共通ルール）

LLM がよく間違えるので最初に明記します。

| 種類 | 書き方 | 注意 |
|------|--------|------|
| 座標 `position` | `{ "x": 640, "y": 360 }` または top-level `"x": 640, "y": 360` | **中心座標**。左上ではない |
| サイズ `size` | `{ "width": 400, "height": 100 }` または `"width": 400, "height": 100` | px |
| 色 | `"#RRGGBB"` または `"#RRGGBBAA"`（末尾 2 桁は不透明度） | `rgb()`・色名（`"red"`）は**不可**。必ず HEX |
| `rotation` | number（度） | -180〜180 |
| `opacity` | number | 0.0〜1.0 |

**よくある間違い（避けること）:**
- `"type"` は厳密一致。`"effectOverlay"` を `"effect_overlay"` や `"mosaic"` と書かない。
- `"id"` / `"zIndex"` は**書かない**（アプリが自動採番）。
- 色を `"red"` や `"rgb(255,0,0)"` で書かない。`"#FF0000"`。
- Shape は `"shapeType"` が必須。
- 画像は base64 を書かない（§9 参照）。

---

## 5. Text 要素

```json
{
  "type": "text",
  "text": "神回",
  "position": { "x": 640, "y": 360 },
  "rotation": -5,
  "opacity": 1.0,
  "fontName": "Hiragino Sans W7",
  "fontSize": 120,
  "letterSpacing": 5,
  "isVertical": false,
  "horizontalSkewAngle": 0,
  "textFill": { "type": "solid", "color": "#FFFFFF" },
  "outline": { "enabled": true, "width": 6, "color": "#000000" },
  "secondOutline": { "enabled": false, "width": 12, "color": "#FFFFFF" },
  "shadow": { "enabled": true, "color": "#00000080", "radius": 8, "offset": { "x": 5, "y": 5 } }
}
```

| プロパティ | 型 | 必須 | デフォルト | 説明 |
|-----------|-----|:----:|-----------|------|
| `type` | `"text"` | ✅ | - | 要素タイプ |
| `text` | string | ✅ | `"テキスト"` | テキスト内容 |
| `position` | Point | - | `{x:0,y:0}` | 中心座標 |
| `rotation` | number | - | `0` | 回転角度（-180〜180） |
| `opacity` | number | - | `1.0` | 不透明度（0.0〜1.0） |
| `fontName` | string | - | `"Hiragino Sans W7"` | フォント名（§5b） |
| `fontSize` | number | - | `72` | フォントサイズ（pt） |
| `letterSpacing` | number | - | `0` | 文字間隔（pt） |
| `isVertical` | boolean | - | `false` | 縦書き |
| `horizontalSkewAngle` | number | - | `0` | 水平スキュー角度（-45〜45、斜体風） |
| `textFill` | Fill | - | 白 solid | テキストの塗り（§8） |
| `outline` | Outline | - | enabled | 縁取り（袋文字） |
| `secondOutline` | Outline | - | disabled | 二重縁取り（外側にもう一段） |
| `shadow` | Shadow | - | enabled | 影 |

**Outline（縁取り）**: `{ "enabled": true, "width": 4, "color": "#000000" }`
**Shadow（影）**: `{ "enabled": true, "color": "#000000B3", "radius": 4, "offset": { "x": 3, "y": 3 } }`（color の末尾 2 桁で影の濃さを指定）

### 5b. 利用可能フォント

| fontName | 表示名 | 特徴 |
|----------|--------|------|
| `Keifont` | けいふぉんと！ | ポップ、丸み |
| `851CHIKARA-DZUYOKU-KANA-A` | 851チカラヅヨク | 力強い、太い |
| `Reggae One` | レゲエ One | カジュアル |
| `Corporate-Logo-Bold-ver3` | コーポレート・ロゴ | 企業ロゴ風 |
| `MochiyPopOne-Regular` | もっちーぽっぷ | 丸みのあるポップ |
| `Tanuki-Permanent-Marker` | たぬき油性マジック | 手書き風マーカー |
| `LightNovelPopV2-V2` | ラノベPOP | ライトノベル風 |
| `Hiragino Sans W8` | ヒラギノ角ゴ W8 | 最太ゴシック |
| `Hiragino Sans W7` | ヒラギノ角ゴ W7 | 極太ゴシック |
| `Hiragino Sans W6` | ヒラギノ角ゴ W6 | 太ゴシック |
| `Hiragino Sans W5` | ヒラギノ角ゴ W5 | 中太ゴシック |
| `Hiragino Sans W3` | ヒラギノ角ゴ W3 | 標準ゴシック |
| `Hiragino Mincho ProN W6` | ヒラギノ明朝 W6 | 太明朝 |
| `Hiragino Mincho ProN W3` | ヒラギノ明朝 W3 | 標準明朝 |
| `Toppan Bunkyu Midashi Gothic Extrabold` | 凸版文久見出しゴシック | 見出し用極太 |
| `Helvetica Neue Bold` | Helvetica Bold | 欧文太字 |
| `Helvetica Neue` | Helvetica | 欧文標準 |
| `Arial Black` | Arial Black | 欧文極太 |
| `Impact` | Impact | インパクト |
| `Futura Bold` | Futura Bold | モダン太字 |

---

## 6. Shape 要素

```json
{
  "type": "shape",
  "shapeType": "rectangle",
  "position": { "x": 640, "y": 600 },
  "size": { "width": 400, "height": 80 },
  "rotation": 0,
  "fill": { "type": "solid", "color": "#FF0000" },
  "strokeColor": "#000000",
  "strokeWidth": 2,
  "cornerRadius": 20,
  "shadow": { "enabled": true, "color": "#00000066", "radius": 8, "offset": { "x": 4, "y": 4 } }
}
```

| プロパティ | 型 | 必須 | デフォルト | 説明 |
|-----------|-----|:----:|-----------|------|
| `type` | `"shape"` | ✅ | - | 要素タイプ |
| `shapeType` | string | ✅ | - | 図形の種類（下記） |
| `position` | Point | - | `{x:0,y:0}` | 中心座標 |
| `size` | Size | - | `{width:200,height:200}` | サイズ（1〜10000） |
| `rotation` | number | - | `0` | 回転角度 |
| `fill` | Fill | - | - | 塗り（§8） |
| `strokeColor` | string | - | `"#4D4D4D"` | 線の色（HEX） |
| `strokeWidth` | number | - | `2` | 線の太さ（0〜100 pt） |
| `cornerRadius` | number | - | `8` | 角丸半径（rectangle のみ、0〜1000） |
| `sides` | number | - | `5` | 辺数/頂点数（polygon・star のみ、3〜12） |
| `shadow` | Shadow | - | disabled | 影 |

**shapeType の値:**

| 値 | 説明 | 追加オプション |
|----|------|---------------|
| `rectangle` | 矩形 | `cornerRadius` |
| `circle` | 円/楕円 | - |
| `triangle` | 三角形 | - |
| `star` | 星 | `sides`（頂点数） |
| `polygon` | 正多角形 | `sides`（辺数） |
| `arrow` | 矢印 | - |

---

## 7. EffectOverlay 要素（モザイク）

背面のキャンバス内容を加工して隠す独立オブジェクト。現バージョンは `mosaic` のみ対応。

```json
{
  "type": "effectOverlay",
  "effectType": "mosaic",
  "position": { "x": 640, "y": 360 },
  "size": { "width": 500, "height": 100 },
  "rotation": 0,
  "opacity": 1.0,
  "blockSize": 20
}
```

| プロパティ | 型 | 必須 | デフォルト | 説明 |
|-----------|-----|:----:|-----------|------|
| `type` | `"effectOverlay"` | ✅ | - | 要素タイプ |
| `effectType` | string | - | `"mosaic"` | 現在は `"mosaic"` のみ |
| `blockSize` | number | - | `16` | モザイクのブロックサイズ（4〜64 にクランプ） |
| `position` | Point | - | キャンバス中央 | 中心座標 |
| `size` | Size | - | `{width:400,height:120}` | サイズ |
| `rotation` | number | - | `0` | 回転角度 |
| `opacity` | number | - | `1.0` | 不透明度（0.0〜1.0） |

> effectOverlay は自身より背面（後ろ）の描画結果だけを加工し、前面の要素には影響しません。

---

## 8. 塗り（Fill）と色

`textFill` / `fill` は単色またはグラデーションを指定できます。

**単色:**
```json
{ "type": "solid", "color": "#FF0000" }
```

**グラデーション:**
```json
{
  "type": "gradient",
  "gradientType": "linear",
  "angle": 90,
  "stops": [
    { "color": "#FFD700", "position": 0 },
    { "color": "#FFA500", "position": 1 }
  ]
}
```

| フィールド | 説明 |
|-----------|------|
| `gradientType` | `"linear"`（`angle` で角度指定）または `"radial"`（中心から外側） |
| `angle` | linear のときの角度（度） |
| `stops` | **2 つ以上**必須。各 stop は `color`（HEX）+ `position`（0.0〜1.0） |

---

## 9. 画像について（制限）

画像要素は、**ローカル絶対パス（`imagePath`）でのみ**指定できます。

```json
{ "type": "image", "imagePath": "/Users/あなたのユーザー名/Pictures/person.png", "position": { "x": 300, "y": 360 } }
```

- LLM に画像のバイナリ（base64）を書かせないでください。生成できませんし、巨大なテキストになります。
- `imagePath` は **あなたのマシン上に実在するファイルの絶対パス**に置き換えてください。LLM が出力する JSON ではここはプレースホルダーになります。

---

## 10. 制約

- **非破壊マージ**: 既存要素は消えず、追加されます。
- **最大 50 要素**まで（1 回の貼り付け）。
- **重複スキップ**: 同じ位置に同じ属性の要素は重複として弾かれます。
- `id` / `zIndex` は書かない（アプリが自動採番。重なり順は配列の並び順に準じます）。

---

## 11. 完全なサンプル（丸ごとコピー可能）

YouTube サムネイル（1280×720）に、グラデーション帯・タイトル文字・モザイクを配置する例です。

```json
{
  "format": "thumbnailthumb.import",
  "schemaVersion": 1,
  "canvas": { "preset": "youtube" },
  "elements": [
    {
      "type": "shape",
      "shapeType": "rectangle",
      "position": { "x": 640, "y": 620 },
      "size": { "width": 1100, "height": 120 },
      "fill": {
        "type": "gradient",
        "gradientType": "linear",
        "angle": 0,
        "stops": [
          { "color": "#FF0000", "position": 0 },
          { "color": "#FF6600", "position": 1 }
        ]
      },
      "strokeColor": "#000000",
      "strokeWidth": 2,
      "cornerRadius": 24,
      "shadow": { "enabled": true, "color": "#00000066", "radius": 8, "offset": { "x": 4, "y": 4 } }
    },
    {
      "type": "text",
      "text": "神回",
      "position": { "x": 640, "y": 320 },
      "rotation": -5,
      "fontName": "Hiragino Sans W7",
      "fontSize": 200,
      "letterSpacing": 8,
      "textFill": {
        "type": "gradient",
        "gradientType": "linear",
        "angle": 90,
        "stops": [
          { "color": "#FFD700", "position": 0 },
          { "color": "#FFA500", "position": 1 }
        ]
      },
      "outline": { "enabled": true, "width": 8, "color": "#000000" },
      "secondOutline": { "enabled": true, "width": 16, "color": "#FFFFFF" },
      "shadow": { "enabled": true, "color": "#00000080", "radius": 10, "offset": { "x": 6, "y": 6 } }
    },
    {
      "type": "text",
      "text": "衝撃の結末",
      "position": { "x": 640, "y": 620 },
      "fontName": "Hiragino Sans W7",
      "fontSize": 64,
      "textFill": { "type": "solid", "color": "#FFFFFF" },
      "outline": { "enabled": true, "width": 4, "color": "#000000" }
    },
    {
      "type": "effectOverlay",
      "effectType": "mosaic",
      "position": { "x": 1000, "y": 200 },
      "size": { "width": 300, "height": 120 },
      "blockSize": 24
    }
  ]
}
```

---

## 12. ChatGPT への依頼テンプレート

以下を ChatGPT 等に貼り付けて使ってください（`▼▼▼` の部分を書き換え）。

```
あなたは YouTube サムネイルのデザイナーです。以下の仕様に厳密に従い、ThumbnailThumb に貼り付けられる JSON だけを出力してください（説明文は不要）。

# 作りたいサムネイル
▼▼▼ ここに内容を書く（例: 「ゲーム実況『神回』。赤系で派手に。中央に大きくタイトル」）▼▼▼

# 出力ルール（厳守）
- トップレベルは { "format": "thumbnailthumb.import", "schemaVersion": 1, "canvas": { "preset": "youtube" }, "elements": [ ... ] }
- 要素タイプは "text" / "shape" / "effectOverlay" のみ
- 座標 position は中心座標 { "x": ..., "y": ... }、キャンバスは 1280x720
- 色は必ず HEX（"#RRGGBB" か "#RRGGBBAA"）。色名や rgb() は使わない
- "id" と "zIndex" は書かない
- 画像は使わない（image 要素を出力しない）
- 要素は最大 50 個まで
- JSON として正しい構文で、コードブロックに入れて出力する
```

完全な仕様は本ページ（§5〜§9）を参照してください。
