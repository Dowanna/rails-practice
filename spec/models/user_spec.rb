require 'rails_helper'

RSpec.describe User, type: :model do
  before(:each) do
    @user = build(:user)
  end

  it "should be valid" do
    expect(@user.valid?).to be true
  end

  it "should not allow empty name" do
    @user.name = ' '
    expect(@user.valid?).to be false
  end

  it "should save email as downcase" do
    EMAIL = 'HOGE@HOGE.com'
    @user.email = EMAIL
    @user.save
    expect(EMAIL.downcase).to eq @user.reload.email
  end
end