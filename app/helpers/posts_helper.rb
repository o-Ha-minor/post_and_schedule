module PostsHelper
  def post_image_url(post)
    # only_path: true を必ずつける
    rails_blob_path(post.image, only_path: true) if post.image.attached?
  end
end
