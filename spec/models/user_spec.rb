require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:tasks).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'factory' do
    it 'creates a valid user' do
      user = build(:user)
      expect(user).to be_valid
    end
  end

  describe 'dependent destroy' do
    it 'destroys associated tasks when user is destroyed' do
      user = create(:user)
      create_list(:task, 3, user: user)

      expect { user.destroy }.to change { Task.count }.by(-3)
    end
  end
end
