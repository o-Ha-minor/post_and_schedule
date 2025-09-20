# app/controllers/home_controller.rb
class HomeController < ApplicationController
  def spa
    # SPA用の単一HTMLページを返す
    render "layouts/spa", layout: false
  end

  def about
    # 従来通りのRailsビュー（移行期間中）
  end
end
