require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test 'Should require email' do
    user = User.new(:username => 'user', :password => '123456')
    assert_not user.save
  end

  test 'Should require password' do
    user = User.create(:username => 'user', :email => 'user1@gatherbox.com')
    assert_not user.save
  end

  test 'Should require password.length >= 6' do
    user = User.create(:username => 'user', :email => 'user2@gatherbox.com', :password => '123')
    assert_not user.save
  end

  test 'Should control valid email' do
    user = User.create(:username => 'user', :email => 'user3x.test.com', :password => '123456')
    assert_not user.save
  end

  test 'Should have created a new user with encrypted password, and password must now be cleared' do
    user = User.create(:username => 'user', :email => 'user4@gatherbox.com', :password => '123456')
    assert user.save
    assert_not user.encrypted_password.nil? || user.encrypted_password.empty?
    assert user.password.nil?
  end

  test 'Email should already be used' do
    user = User.create(:username => 'fabrice twin', :email => 'fabrice@gatherbox.com', :password => '123456')
    assert_not user.save
  end

end
