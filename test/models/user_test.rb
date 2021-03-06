require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com", 
                    password: "foobar", password_confirmation: "foobar")
  end

  test "should_be_valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name= "      "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email= "      "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name= "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email= "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
    first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |address|
      @user.email = address
      assert @user.valid?, "#{address.inspect} should be valid"
    end
  end

  test "email validation reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
    foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |address|
      @user.email = address
      assert_not @user.valid?, "#{address.inspect} should not be valid."
    end 
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lowercase" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should not be blank" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with a nil token digest" do
    assert_not @user.authenticated?(:remember,'')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
    @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    michael = users(:michael)
    florence = users(:florence)

    assert_not florence.following?(michael)
    florence.follow(michael)
    assert florence.following?(michael)
    assert michael.followers.include?(florence)
    florence.unfollow(michael)
    assert_not florence.following?(michael)
  end

  test "feed should show only followed users posts" do
    michael = users(:michael)
    florence = users(:florence)
    malachi = users(:malachi)

    michael.microposts.each do |micropost|
      assert michael.feed.include?(micropost)
    end

    florence.microposts.each do |micropost|
      assert_not michael.feed.include?(micropost)
    end

    malachi.microposts.each do |micropost|
      assert michael.feed.include?(micropost)
    end
  end
end
