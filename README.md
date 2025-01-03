# aibou.nvim
* 「相棒」と共にコーディングするためのプラグインです。

## 背景
* [CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim) を利用してみて素晴しいプラグインだと感じたのですが、私にとっては高機能すぎて使いこなせないと感じたのと、そもそもチャットをしながらコーディングすることに慣れていなさすぎるので、まずは簡単なところから始めようとしました。

## 使い方
### インストール
* [Lazy.nvim](https://github.com/folke/lazy.nvim)
```
{
  'senkentarou/aibou.nvim',
  cmd = {'AibouOpenChat', 'AibouToggleChat'},
  opts = {},
}

```
* チャットを開く
```
:AibouOpenChat
```
* チャットを閉じる(トグルする)
```
:AibouToggleChat
```
* チャットにおける操作
```
問い掛ける: <C-j>
チャットをクリアする: <C-l>
チャットを閉じる: <C-q>
```

## 留意事項
* デフォルトの相棒は[yesno](https://yesno.wtf/)となっています。問い掛けに対してyesかnoを返してくれます。

## 今後の展望
* LLMな相棒を有効にする
  * トークンを用いた通信に慣れていないので調査から。
* 相棒を切り替えられるようにする
  * 作りとしては複数チャットを可能にしているが、チャットの切り替え方法の上手いやり方が思い付いていない。
