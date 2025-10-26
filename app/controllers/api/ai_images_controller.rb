class Api::AiImagesController < ApplicationController
  skip_before_action :verify_authenticity_token
  # AIキャラ画像の一覧を返す
  def index
    ai_images_dir = Rails.root.join("public", "ai_images")
    all_files = Dir.glob(ai_images_dir.join("*.{png,jpg,jpeg,gif}"))
    name_map = {
      "f" => "ソニア",
      "f2" => "エリカ",
      "m" => "ルイ",
      "m2" => "タケハル",
      "tanuki" => "たぬ郎"
    }
    avatars = all_files.select { |f| f.include?("_neutral") }.map do |path|
      fname = File.basename(path)
      base = fname.split("_").first
      {
        name: base,
        display_name: name_map[base] || base,
        url: "/ai_images/#{fname}"
      }
    end
    render json: { success: true, data: { avatars: avatars } }
  end

  # ユーザーのアバターと感情分析結果を組み合わせた画像 URL を生成
  def generate_image_url
    user = current_user
    unless user
      return render_api_response(message: "ログインが必要です", success: false, status: :unauthorized)
    end

    character = user.ai_character.presence || "tanuki"
    expression = user.ai_expression.presence || "neutral"
    image_path = Rails.root.join("public", "ai_images", "#{character}_#{expression}.png")

    # 画像が存在するか確認
    if File.exist?(image_path)
      render_api_response(data: { image_url: "/ai_images/#{user.ai_character}_#{user.ai_expression}.png" })
    else
      render_api_response(message: "指定された画像が存在しません", success: false, status: :not_found)
    end
  end
end
