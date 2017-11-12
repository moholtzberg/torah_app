module PostsHelper
  def post_time post
    if post.created_at < post.updated_at
      "Edited on #{post.updated_at.strftime('%d %B %Y')}"
    else
      "Posted on #{post.created_at.strftime('%d %B %Y')}"
    end
  end
end
