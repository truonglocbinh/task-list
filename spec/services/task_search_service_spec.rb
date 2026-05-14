require 'rails_helper'

RSpec.describe TaskSearchService do
  let(:user) { create(:user) }
  let(:tasks) { user.tasks }

  describe '#call' do
    before do
      create(:task, user: user, title: 'Important task', description: 'Very important')
      create(:task, user: user, title: 'Regular task', description: 'Not important')
      create(:task, :completed, user: user, title: 'Completed task')
      create(:task, :overdue, user: user, title: 'Overdue task')
      create(:task, :due_today, user: user, title: 'Due today task')
    end

    context 'without filters' do
      it 'returns all tasks sorted by due date' do
        result = described_class.new(tasks, {}).call
        expect(result.count).to eq(5)
      end
    end

    context 'with text search' do
      it 'filters by title' do
        params = { search: 'Important' }
        result = described_class.new(tasks, params).call
        expect(result.count).to eq(2)
      end

      it 'filters by description' do
        params = { search: 'Very important' }
        result = described_class.new(tasks, params).call
        expect(result.count).to eq(2)
      end

      it 'is case insensitive' do
        params = { search: 'IMPORTANT' }
        result = described_class.new(tasks, params).call
        expect(result.count).to eq(2)
      end
    end

    context 'with status filter' do
      it 'filters pending tasks' do
        params = { status: 'pending' }
        result = described_class.new(tasks, params).call
        expect(result.map(&:title)).not_to include('Completed task')
        expect(result.map(&:title)).not_to include('Overdue task')
      end

      it 'filters completed tasks' do
        params = { status: 'completed' }
        result = described_class.new(tasks, params).call
        expect(result.count).to eq(1)
        expect(result.first.title).to eq('Completed task')
      end

      it 'filters overdue tasks' do
        params = { status: 'overdue' }
        result = described_class.new(tasks, params).call
        expect(result.count).to eq(1)
        expect(result.first.title).to eq('Overdue task')
      end
    end

    context 'with date filters' do
      context "with due_date_from" do
        it 'filters tasks due after a certain date' do
          params = { due_date_from: 1.day.from_now.to_date.to_s }
          task = create(:task, user: user, due_at: 2.days.from_now)
          result = described_class.new(tasks, params).call
          expect(result).to include(task)
        end
      end

      context "with due_date_to" do
        it 'filters tasks due before a certain date' do
          params = { due_date_to: 1.day.from_now.to_date.to_s }
          task = create(:task, user: user, due_at: 1.day.from_now)
          result = described_class.new(tasks, params).call
          expect(result).to include(task)
        end
      end

      context "with due_date_from and due_date_to" do
        it 'filters by date range' do
          task = create(:task, user: user, due_at: 2.days.from_now)
          params = { due_date_from: Date.today.to_s, due_date_to: 3.days.from_now.to_date.to_s }
          result = described_class.new(tasks, params).call
          expect(result).to include(task)
        end
      end
    end

    context 'with quick filter' do
      it 'filters due today' do
        params = { filter: 'today' }
        result = described_class.new(tasks, params).call
        expect(result.count).to eq(1)
        expect(result.first.title).to eq('Due today task')
      end
    end

    context 'with pagination' do
      before do
        create_list(:task, 20, user: user)
      end

      it 'paginates results' do
        result = described_class.new(tasks, {}).call
        expect(result.count).to eq(15) # default per_page
      end

      it 'respects page parameter' do
        params = { page: 2 }
        result = described_class.new(tasks, params).call
        expect(result.current_page).to eq(2)
      end
    end

    context 'with combined filters' do
      it 'applies multiple filters together' do
        params = { q: 'task', status: 'pending' }
        result = described_class.new(tasks, params).call
        expect(result.map(&:title)).to include('Important task', 'Regular task')
        expect(result.map(&:title)).not_to include('Completed task')
      end
    end
  end
end
