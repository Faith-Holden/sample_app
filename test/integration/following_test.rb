require "test_helper"

class FollowingTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:florence)
    log_in_as(@user)
  end

  test "should follow user non-ajax method" do
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: {followed_id: @other_user.id}
    end
  end

  test "should follow user ajax method" do
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: {followed_id: @other_user.id}, xhr: true
    end
  end

  test "should unfollow user non-ajax method" do
    @user.follow(@other_user)
    relationship = @user.active_relationships.find_by(followed_id: @other_user.id)
    assert_difference '@user.following.count',-1 do
      delete relationship_path(relationship)
    end
  end

  test "should unfollow user ajax method" do
    @user.follow(@other_user)
    relationship = @user.active_relationships.find_by(followed_id: @other_user.id)
    assert_difference '@user.following.count',-1 do
      delete relationship_path(relationship), xhr: true
    end
  end

  test "following page" do
    get following_user_path(@user)
    assert_not @user.following.empty?
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    get followers_user_path(@user)
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end
end
