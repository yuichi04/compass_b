class User < ApplicationRecord
	before_save { self.email = email.downcase }
	validates :name, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum:255 },
										format: { with: VALID_EMAIL_REGEX },
										uniqueness: { case_sensitive: false }
	has_secure_password
	with_options on: :create do
		validates :password, presence: true, length: { minimum: 8 }
	end
	
	with_options on: :update_pass do
		validates :password, presence: true, length: { minimum: 8 }
	end
end