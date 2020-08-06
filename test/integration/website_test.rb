require "test_helper"

class WebsiteTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get "/"

    assert_response :success
  end

  test "that someone can't donate to no charity" do
    stub_donation_post("100", "tokn_X", "")

    assert_template :index
    assert_equal t("website.donate.failure"), flash.now[:alert]
  end

  test "that someone can't donate 0 to a charity" do
    charity = charities(:children)
    stub_donation_post("0", "tokn_X", charity.id)

    assert_template :index
    assert_equal t("website.donate.failure"), flash.now[:alert]
  end

  test "that someone can't donate less than 20 to a charity" do
    charity = charities(:children)
    stub_donation_post("19", "tokn_X", charity.id)

    assert_template :index
    assert_equal t("website.donate.failure"), flash.now[:alert]
  end

  test "that someone can't donate without a token" do
    charity = charities(:children)
    stub_donation_post("100", nil, charity.id)

    assert_template :index
    assert_equal t("website.donate.failure"), flash.now[:alert]
  end

  test "that someone can donate to a charity" do
    charity = charities(:children)
    initial_total = charity.total
    expected_total = initial_total + (100 * 100)

    stub_donation_post("100", "tokn_X", charity.id)
    follow_redirect!

    assert_template :index
    assert_equal t("website.donate.success"), flash[:notice]
    assert_equal expected_total, charity.reload.total
  end

  test "that if the charge fail from omise side it shows an error" do
    charity = charities(:children)

    # 999 is used to set paid as false
    stub_donation_post("999", "tokn_X", charity.id)

    assert_template :index
    assert_equal t("website.donate.failure"), flash.now[:alert]
  end

  test "that we can donate to a charity at random" do
    charities = Charity.all
    initial_total = charities.to_a.sum(&:total)
    expected_total = initial_total + (100 * 100)

    stub_donation_post("100", "tokn_X", "random")
    follow_redirect!

    assert_template :index
    assert_equal expected_total, charities.to_a.map(&:reload).sum(&:total)
    assert_equal t("website.donate.success"), flash[:notice]
  end

  test "that we can donate Bahts and Satangs" do
    charity = charities(:children)
    initial_total = charity.total
    expected_total = initial_total + (77.77 * 100).to_i

    stub_donation_post("77.77", "tokn_X", charity.id)
    follow_redirect!

    assert_template :index
    assert_equal t("website.donate.success"), flash[:notice]
    assert_equal expected_total, charity.reload.total
  end

  test "that we can't donate less than a Satang" do
    charity = charities(:children)
    initial_total = charity.total
    expected_total = initial_total + (77.77 * 100).to_i

    stub_donation_post("77.77111111111", "tokn_X", charity.id)
    follow_redirect!

    assert_template :index
    assert_equal t("website.donate.success"), flash[:notice]
    assert_equal expected_total, charity.reload.total
  end
end
