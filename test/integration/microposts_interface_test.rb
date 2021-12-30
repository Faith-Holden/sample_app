require "test_helper"

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:florence)
    @third_user = users(:faith)
  end

  test "micropost creation and deletion" do
    log_in_as @user
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]'
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: {micropost: {content: ""}}
    end
    assert_select 'div#error_explanation'

    content = "Lorem ipsum"
    image = fixture_file_upload('test/fixtures/kittens.jpg', 'image/jpg', :binary)
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: {micropost: {content: content, image: image}}
    end
    micropost = assigns(:micropost)
    assert micropost.image.attached?
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body

    micropost = @user.microposts.paginate(page: 1).first
    assert_select 'a', text: "delete"
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(micropost)
    end


    get user_path(@other_user)
    assert_select 'a', text: "delete", count: 0
  end


  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body
    log_in_as(@third_user)
    get root_path
    assert_match "0 microposts", response.body
    @third_user.microposts.create!(content: "Lorem ipsum")
    get root_path
    assert_match "1 micropost", response.body
  end

end
