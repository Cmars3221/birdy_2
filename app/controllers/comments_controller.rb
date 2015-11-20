class CommentsController < ApplicationController
  before_action  :authenticate_user!

 #  def edit
 #  end

 #  def new
 #  end

 #  def show
 #    @comments = Comment.all('created_at DESC')
 #  end

 #  def create
 #    @post = Post.find(params[:post_id])
 #    @comment = @post.comments.create(comment_params)
 #    redirect_to @comment.post
 #  end
  
 #  def destroy
 #    @post = Post.find(params[:post_id])
 #    @comment = @post.comments.find(params[:id])
 #    @comment.destroy
 #    redirect_to posts_path
 #  end

 # private
 #  def comment_params
 #      params.require(:comment).permit(:comment_body).merge(user_id: current_user.id, post_id: params[:post_id])
 #  end

end