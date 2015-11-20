class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessor :login

  def self.find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      if login = conditions.delete(:login)
        where(conditions).where(["username = :value OR lower(email) = lower(:value)", { :value => login }]).first
      else
      	conditions[:email].downcase! if conditions[:email]
        where(conditions.to_hash).first
      end
  end
  
  validates :username, presence: true, length: {maximum: 255}, uniqueness: { case_sensitive: false }, format: { with: /\A[a-zA-Z0-9]*\z/, message: "may only contain letters and numbers." }

  has_many :comments

  has_attached_file :avatar, styles: { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "Unknown.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
  
end