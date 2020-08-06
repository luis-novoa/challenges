ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/autorun'

class ActiveSupport::TestCase
  fixtures :all

  private

  def t(*args)
    I18n.t(*args)
  end

  def sign_in_user(email, password)
    get new_user_session_path
    post(user_session_path, params: {
           user: {
             email: email,
             password: password
           }
         })
    follow_redirect!
  end

  def assert_follow_link(path)
    assert_select "a[href='#{path}']"
    get path
  end

  def stub_donation_post(amount, omise_token, charity_id)
    stub_charge = OpenStruct.new({
      amount: (amount.to_f * 100).to_i,
      paid: (amount.to_i != 999)
    })

    stub_token = OpenStruct.new({
      id: "tokn_X",
      card: OpenStruct.new({
        name: "J DOE",
        last_digits: "4242",
        expiration_month: 10,
        expiration_year: 2020,
        security_code_check: false,
        })
      })
      

    Omise::Charge.stub :create, stub_charge do
      Omise::Token.stub :retrieve, stub_token do
        post(donate_path, params: {
          amount: amount, omise_token: omise_token, charity: charity_id
        })
      end
    end

  end
end
