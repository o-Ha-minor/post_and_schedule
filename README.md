#  Post and Schedule

Post and Schedule は、ユーザーが投稿・コメント・タスク管理・予定（イベント）を行える Ruby on Rails で作成したWebアプリケーションです。  
日々の記録やスケジュールの可視化、他者とのリアクション（コメント・いいね）を通じて、共通スケジュールの管理と交流をサポートします。

作ろうと思った経緯として、趣味の音楽仲間との間で、下記の課題がありました。
１、スケジュール管理
　会う日程がまとまらなかったり、忘れたりしてしまう。
２、To Doの管理
　音楽の課題や必要な事務が共有できていない。
３、話題の管理
　次にやりたい曲や、練習するべき場所など、話題が散在してしまいまとまらない。

そこで、Post and scheduleを利用することで、上記課題を解決することができました。

##  使用技術

- フレームワーク: Ruby on Rails 8.0.1
- 言語: Ruby, JavaScript, HTML, CSS
- フロントエンド: importmap, Rails UJS
- データベース: SQLite3（開発環境）
- デプロイ: Render（※無料プラン使用経験あり）、AWS移行検討中
- セキュリティ: brakeman（静的コード解析）
- 画像アップロード: ActiveStorage（アバター機能で使用）

##  主な機能

-   投稿（Post）
  - ユーザーによる自由な投稿（画像アップロード対応）
  - コメント・いいね機能付き

-   コメント（Comment）
  - 投稿に対するコメント
  - ユーザー間のやり取りが可能

-   いいね（Like）
  - 投稿へのリアクション機能

-   タスク管理（Task）
  - 日々のタスク登録・一覧表示
  - カレンダーと連携した可視化

-   イベント（Event）
  - スケジュールの追加・表示
  - タスクと合わせたカレンダー管理

-   ユーザー管理（User）
  - `if @user&.authenticate(params[:password])` による独自認証あり
  - ※現在、`Devise`などの認証ライブラリは未使用

##  ディレクトリ構成（一部）

app/
├── assets/
├── controllers/
├── javascript/
├── jobs/
├── mailers/
├── models/
└── views/


##  セットアップ手順（開発環境）

git clone https://github.com/o-Ha-minor/post_and_schedule.git
cd post_and_schedule

bundle install
rails db:create
rails db:migrate

rails s


アクセス: http://localhost:3000

##  投稿画像について

投稿に画像を添付可能。  
ファイルアップロードには ActiveStorage を使用。  
ユーザーのアバターなどでも活用中。

##  今後の予定・ToDo

- [ ] Deviseによるユーザー認証の導入
- [ ] テストの追加（RSpec or Minitest）
- [ ] UI/UXの改善・デザイン統一
- [ ] READMEに画面キャプチャやGIFの追加
- [ ] AWSへの本番デプロイ対応

## 👤 作者

- **名前**：o-Ha-minor
- **経歴**：公務員事務職8年目 → ITエンジニア転職を目指して開発中  
- **資格**：基本情報技術者、ITパスポート、AWSクラウドプラクティショナー、Python3基礎
- **学習中**：Rails, Python, AWS, HTML/CSS, Photoshop