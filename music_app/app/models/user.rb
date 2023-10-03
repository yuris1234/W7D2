# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :string           not null
#  password_digest :string           not null
#  session_token   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class User < ApplicationRecord
    before_validation :ensure_session_token
    validates :email, :session_token, presence: true, uniqueness: true 
    validates :password_digest, presence: true
    validates :session_token, uniqueness: {scope: :email}
    validates :password, length: {minimum: 6, allow_nil: true}

    attr_reader :password

    def ensure_session_token # ensures that session token exists?
        self.session_token ||= generate_unique_session_token
    end

    def reset_session_token! # resets session token of user to logout, also so that session token of past sessions is not the same
        self.session_token = generate_unique_session_token
        self.save!
        self.session_token
    end

    def password=(password)
        @password = password 
        self.password_digest = BCrypt::Password.create(password)
    end

    def is_password?(password)
        password_obj = BCrypt::Password.new(self.password_digest)
        password_obj.is_password?(password)
    end

    def self.find_by_credentials(email, password)
        user = User.find_by(email: email)
        if user&.is_password?(password)
            user 
        else
            nil
        end
    end

    private
    def generate_unique_session_token
        SecureRandom::urlsafe_base64
    end
end
