class Api::AiImagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  # ユーザーのアバターと感情分析結果を組み合わせた画像 URL を生成
  def generate_image_url
    user = current_user

    # 必要なデータが揃っているか確認
    if user.ai_character.blank? || user.ai_expression.blank?
      return render_api_response(message: "アバターまたは感情分析結果が設定されていません", success: false, status: :unprocessable_entity)
    end

    # 画像 URL を生成
    image_url = "/ai_images/#{user.ai_character}_#{user.ai_expression}.png"

    # 画像が存在するか確認
    if File.exist?(Rails.root.join("public", image_url))
      render_api_response(message: "画像 URL を生成しました", data: { image_url: image_url })
    else
      render_api_response(message: "指定された画像が存在しません", success: false, status: :not_found)
    end
  end
end
