# Post and Schedule（POST-Them）

![Rails](https://img.shields.io/badge/Ruby_on_Rails-8.0.1-red?logo=rubyonrails&logoColor=white)
![Vue](https://img.shields.io/badge/Vue.js-3.x-4FC08D?logo=vue.js&logoColor=white)
![TailwindCSS](https://img.shields.io/badge/Tailwind_CSS-3.x-06B6D4?logo=tailwindcss&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-EC2-orange?logo=amazon-aws&logoColor=white)
![Python](https://img.shields.io/badge/Python-Flask_BERT-blue?logo=python&logoColor=white)

---

## 🧭 概要
**Post and Schedule（POST-Them）** は、  
**投稿・コメント・タスク・スケジュールを一元管理できるフルスタックWebアプリケーション**です。

趣味の音楽活動や個人プロジェクトの中で生まれた  
「スケジュール・話題・タスクの分散管理」を解決するために開発しました。

**Rails × Vue × AWS × ChatGPT API** を統合し、  
AI感情分析に応じてコメントやキャラクター画像が変化する、  
“感情に寄り添うチーム管理アプリ”です。

---

## 🎯 制作の目的
- チームでの予定・話題・タスクを統合管理できる実践的Webアプリを構築  
- RailsとVueを分離構成で連携し、SPAとしてUX向上を実現  
- GPT APIによるAI感情分析と、Rails側での統合を経験  
- AWS EC2で本番環境を構築し、インフラ理解を深める  

---

## 🧩 使用技術

| 分類 | 技術 |
|------|------|
| フレームワーク | Ruby on Rails 8.0.1 / Vite / Vue 3 / Pinia |
| フロントエンド | Tailwind CSS / Vue Router / Toastification |
| バックエンド | Ruby 3.3.6 / CSRFトークン認証 |
| データベース | PostgreSQL |
| AI連携 | Chat GPT API |
| インフラ | AWS EC2 (Ubuntu, Nginx, Puma) |
| セキュリティ | Brakeman / RuboCop / CSRF対策 |
| その他 | GitHub Actions / ActiveStorage（画像管理） |

---

## 💡 主な機能

| 機能 | 概要 |
|------|------|
| 📝 投稿 | 画像付き投稿（コメント・いいね対応） |
| 💬 コメント | AI感情分析に基づいたコメント生成機能（GPT API連携） |
| 🗓️ スケジュール | イベント追加・表示・編集（FullCalendar連携） |
| ✅ タスク | カレンダーと連携したToDo管理機能 |
| 🎭 AIキャラクター画像 | 感情分析結果（positive / neutral / negative）に応じて表情を変化 |
| 👥 グループ機能 | ユーザーがグループに参加・脱退できる機能を実装 |
| 👤 ユーザー管理 | ログイン・新規登録・プロフィール画像対応 |
| 🔐 セッション管理 | Cookie＋CSRFトークンベースの安全な認証方式 |

---

## 🧰 開発環境セットアップ
```Bash
git clone https://github.com/o-Ha-minor/post_and_schedule.git
cd post_and_schedule
bundle install
rails db:create db:migrate
```
# フロントエンド
bin/vite dev

# Railsサーバ起動
rails s

アクセス先: http://localhost:3000

## 🚀 デプロイ環境
- AWS EC2 (Ubuntu 22.04)
- Nginx + Puma 構成
- SSL対応準備中
- `RAILS_ENV=production` で assets:precompile 済み  

🔗 **本番URL**: [http://54.65.172.159/](http://54.65.172.159/)

---

## 🎨 UI/UXの工夫
- Tailwindで作成した柔らかい「付箋風UI」  
- SPA化によるスムーズな画面遷移  
- トースト通知で操作感を即時フィードバック  
- AI感情分析結果に応じてAIキャラ画像を投稿コメント近くに表示  
  （positive：微笑 / neutral：穏やか / negative：落ち込み）

---

## 📈 今後の展望
- [ ] 画像アップロードのS3移行  
- [ ] HTTPS化（Let’s Encrypt）  
- [ ] AIキャラのカスタマイズ機能拡張（ユーザーによる画像の設定など）  
- [ ] 開発ドキュメント（ER図・設計書）の整備  

---

## 📷 画面イメージ
> ※今後スクリーンショットまたはGIFを追加予定  
> - 投稿一覧  
> - カレンダー（タスク連携）  
> - AIコメントとキャラクター表示部分  

---

## 👤 作者

| 項目 | 内容 |
|------|------|
| 名前 | o-Ha-minor（たか） |
| 経歴 | 公務員事務職 → ITエンジニア転職を目指して開発中 |
| 保有資格 | 基本情報技術者 / 応用情報技術者 / AWSクラウドプラクティショナー / Python3基礎認定 |
| 学習中 | Rails / Python / AWS SAA / HTML / Photoshop |
| 趣味 | 音楽 / 写真 / 自転車 / アニメ |
| SNS | [GitHub](https://github.com/o-Ha-minor) |

---

## 🧠 学んだこと
- **Rails×Vue構成によるSPA設計とAPI連携**  
- **CSRF・CORS・Cookie認証の理解と実装**  
- **AWS本番環境構築・デプロイ**  
- **AI感情分析APIとWebアプリの統合**  

---

## 🏁 一言
> 「チームの“想い”と“予定”を、ひとつのアプリでつなぐ。」  
> Post and Schedule は、その小さな挑戦から始まりました。  
> 今後もAI・クラウド・UIデザインを磨き、ユーザー体験をより豊かにしていきます。


