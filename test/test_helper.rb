ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionController::TestCase

  def signin_as(user)
    @request.session[:user] = user ? user.id : nil
    @current_user = user
  end

  def current_user
    @current_user
  end

  def current_user?(user)
    user == @current_user
  end

end

class ActionDispatch::IntegrationTest

  def signin(username, password)
    post_via_redirect('/sessions',
                      'session[username]' => username,
                      'session[password]' => password)
  end

end