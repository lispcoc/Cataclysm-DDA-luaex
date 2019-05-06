Cataclysm: DDA Lua Extension

■サポートVersion
0.D-8909相当

■はじめに
本ファイルはCataclysm: DDA(CDDA)のLuaサポート機能(バージョン0.D開発版で削除)を復活・拡張したMOD(独自ビルド)です。
・本家CDDAと(基本的に)動作に互換性があります。(本家で発生しないバグがある可能性あり)
・実行ファイル(exeファイル)を変更するため、
  サポートしているVersion以外のセーブデータを移行してきた場合は正常動作しない可能性があります。

■使用上の注意
・本MODはCDDA公式の開発チームとは無関係で制作しています。
  ご質問・ご要望・バグ報告は公式フォーラムではなく、
  下記リンクのGitHubリポジトリにてIssueを投稿する形でお願いします。
・本MODを使用して発生したセーブデータの破損等については
  一切の責任を負いかねますので、ご容赦ください。

■使い方
cataclysm-tiles(.exe)からゲームを開始してください。

■内容物について(主な本体との差分のみ)
・cataclysm-tiles.exe          …  Windows用実行ファイル本体
・cataclysm-tiles              …  Linux 64bit用実行ファイル本体 ※準備中
・lua\                         …  Luaサポート用ファイル
・sample_mods\                 …  MODサンプルコード ※準備中

■リンク
・GitHubリポジトリ
  https://github.com/lispcoc/Cataclysm-DDA/tree/lua-extension

■Luaサポートの状況について(MOD開発者向け)
※執筆中
・Luaコールバック
・アイテム使用時のLuaスクリプト
  概ね0.D安定版と同じように使えると思います。

・C++側クラスのLuaへの公開状況
  同梱のlua/lua_classes.luaを参照してください。
  クラス関数・変数へのアクセスの仕方は0.D安定版と同じように使えると思います。
  ※引数や戻り値の名前にC++のconstや&、*等の修飾子がついていますが、
    これらはコード生成上の都合で付けているものなのでLuaから呼び出すときは無視してください。

・C++のEnum(定数型)の読み出し方
  Enumはグローバル変数enumsにテーブルとして格納されます。
  body_partであれば「enums.body_part.bp_torso」のように読み出せます。
  どのような定数があるかはlua/lua_classes.luaを参照してください。

■更新履歴
※本家CDDAへの追従は随時行っています
準備中…
