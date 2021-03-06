require 'shared_user'

class User
  include DataMapper::Resource

  property :id, Serial
  property :username, String
  property :facebook_token, String

  ## Database authenticatable
  property :email,              String, :required => true, :default => ""
  property :encrypted_password, String, :required => true, :default => "", :length => 255

  ## Recoverable
  property :reset_password_token,   String
  property :reset_password_sent_at, DateTime

  ## Rememberable
  property :remember_created_at, DateTime

  ## Trackable
  property :sign_in_count,      Integer, :default => 0
  property :current_sign_in_at, DateTime
  property :last_sign_in_at,    DateTime
  property :current_sign_in_ip, String
  property :last_sign_in_ip,    String

  ## Encryptable
  # property :password_salt, String

  ## Confirmable
  property :confirmation_token,   String, :writer => :private
  property :confirmed_at,         DateTime
  property :confirmation_sent_at, DateTime
  # property :unconfirmed_email,    String # Only if using reconfirmable

  ## Lockable
  property :failed_attempts, Integer, :default => 0 # Only if lock strategy is :failed_attempts
  property :unlock_token,    String # Only if unlock strategy is :email or :both
  property :locked_at,       DateTime

  # Token authenticatable
  property :authentication_token, String, :length => 255
  timestamps :at

  class << self
    # attr_accessible is used by SharedUser. Instead of trying to make a
    # a compatibility method, ignore it and set writer option to private on
    # confirmation_token property.
    def attr_accessible(*args); nil; end
  end

  include SharedUser
  include Shim

  if VALIDATION_LIB == 'dm-validations'
    before :valid?, :update_password_confirmation

    # DM's validates_confirmation_of requires the confirmation property to be present,
    # while ActiveModel by default skips the confirmation test if the confirmation
    # value is nil. This test takes advantage of AM's behavior, so just add the
    # :password_confirmation value.
    def update_password_confirmation
      if self.password && self.password_confirmation.nil?
        self.password_confirmation = self.password
      end
    end
  end
end

# Define UserWithValidation here (instead of waiting for definition in
# devise/test/models_test.rb) to ensure it is finalized. Otherwise,
# DatabaseAuthenticatableTest 'should run validations even when current password is invalid or blank' fails.
class UserWithValidation < User
  validates_presence_of :username
end
