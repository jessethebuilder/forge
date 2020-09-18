module FeatureSpecHelper
  def setup_feature_spec
    @account = create(:account)
    @user = create(:user, account: @account, password: ENV.fetch('PASSWORD'))
    sign_in_user
  end

  def sign_in_user
    visit '/users/sign_in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: ENV.fetch('PASSWORD')
    click_button 'Sign in'
  end

  def menu_min
    visit '/menus/new'
    fill_in 'Name', with: 'name'
  end

  def product_min
    visit '/products/new'
    fill_in 'Price', with: 13.22
    fill_in 'Name', with: 'name'
  end

  def group_min
    visit '/groups/new'
    fill_in 'Name', with: 'name'
  end

  def account_min(
    account_params: attributes_for(:account),
    credential_params: attributes_for(:credential),
    user_params: attributes_for(:user)
  )
    visit '/'
    fill_in 'Email', with: account_params[:contact_email]
    fill_in 'Password', with: user_params[:password]
    fill_in 'Username', with: credential_params[:username]
  end
end
