class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username, format: { with: /\A[0-9A-Za-z]+\z/ }

  has_many :tweets
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  has_many :favorites
  has_many :favorite_tweets, through: :favorites, source: :tweet

  def favorite?(tweet)
    favorites.find_by(tweet_id: tweet.id)
  end

  def favorite!(tweet)
    favorites.create!(tweet_id: tweet.id)
  end

  def unfavorite!(tweet)
    favorites.find_by(tweet_id: tweet.id).destroy
  end


  def following?(other_user)
    active_relationships.find_by(followed_id: other_user.id)
  end

  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  def feed
    Tweet.from_users_followed_by(self)
  end

  def self.recommend(user)
    recommend = where.not(id:user.id)
    unfollow_recommend = recommend.reject {|recommend| user.following?(recommend)}
    unfollow_recommend.sample(4)
  end

    # allow users to update their accounts without passwords
   def update_without_current_password(params, *options)
     params.delete(:current_password)

     if params[:password].blank? && params[:password_confirmation].blank?
       params.delete(:password)
       params.delete(:password_confirmation)
     end

     result = update_attributes(params, *options)
     clean_up_passwords
     result
   end

   mount_uploader :header_img, HeaderImgUploader
   mount_uploader :user_img, UserImgUploader

end
