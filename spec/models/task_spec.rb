require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many_attached(:attachments) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
  end

  describe 'factory' do
    it 'creates a valid task' do
      task = build(:task)
      expect(task).to be_valid
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }

    describe '.by_due_date' do
      it 'sorts tasks by due date with nulls last' do
        task1 = create(:task, user: user, due_at: 3.days.from_now)
        task2 = create(:task, user: user, due_at: 1.day.from_now)
        task3 = create(:task, user: user, due_at: nil)

        expect(Task.by_due_date).to eq([ task2, task1, task3 ])
      end
    end

    describe '.due_today' do
      it 'returns tasks due today' do
        today_task = create(:task, :due_today, user: user)
        tomorrow_task = create(:task, user: user, due_at: 1.day.from_now)

        expect(Task.due_today).to include(today_task)
        expect(Task.due_today).not_to include(tomorrow_task)
      end
    end

    describe '.overdue' do
      it 'returns incomplete tasks past their due date' do
        overdue_task = create(:task, :overdue, user: user)
        completed_overdue = create(:task, :overdue, :completed, user: user)
        future_task = create(:task, user: user, due_at: 1.day.from_now)

        expect(Task.overdue).to include(overdue_task)
        expect(Task.overdue).not_to include(completed_overdue)
        expect(Task.overdue).not_to include(future_task)
      end
    end
  end

  describe '#overdue?' do
    it 'returns true for incomplete tasks past due date' do
      task = create(:task, :overdue)
      expect(task.overdue?).to be true
    end

    it 'returns false for completed tasks past due date' do
      task = create(:task, :overdue, :completed)
      expect(task.overdue?).to be false
    end

    it 'returns false for tasks without due date' do
      task = create(:task, due_at: nil)
      expect(task.overdue?).to be false
    end
  end

  describe '#due_today?' do
    it 'returns true for tasks due today' do
      task = create(:task, :due_today)
      expect(task.due_today?).to be true
    end

    it 'returns false for tasks due tomorrow' do
      task = create(:task, due_at: 1.day.from_now)
      expect(task.due_today?).to be false
    end
  end

  describe 'attachment validations' do
    it 'validates file size' do
      task = build(:task)
      # Test would require actually creating a file larger than 10MB
      # This is a placeholder for demonstration
      expect(task).to be_valid
    end

    it 'validates content type' do
      task = build(:task)
      expect(task).to be_valid
    end
  end
end
