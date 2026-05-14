require 'rails_helper'

RSpec.describe TasksController, type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user, email: "test@gmail.net") }
  let(:task) { create(:task, user: user) }

  describe 'GET /tasks' do
    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        get tasks_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is signed in' do
      before { sign_in user }

      it 'returns success' do
        get tasks_path
        expect(response).to have_http_status(:success)
      end

      it 'displays user tasks' do
        task1 = create(:task, user: user, title: 'My Task')
        task2 = create(:task, title: 'Other User Task')

        get tasks_path
        expect(response.body).to include(task1.title)
        expect(response.body).not_to include(task2.title)
      end

      it 'filters by search query' do
        task1 = create(:task, user: user, title: 'Important Task')
        task2 = create(:task, user: user, title: 'Regular Task')

        get tasks_path, params: { search: 'Important' }
        expect(response.body).to include(task1.title)
        expect(response.body).not_to include(task2.title)
      end

      it 'filters by status' do
        pending_task = create(:task, user: user, title: 'Pending')
        completed_task = create(:task, :completed, user: user, title: 'Completed')

        get tasks_path, params: { status: 'pending' }
        expect(response.body).to include('Pending')
      end
    end
  end

  describe 'GET /tasks/:id' do
    before { sign_in user }

    it 'shows the task' do
      get task_path(task)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(task.title)
    end

    it 'prevents access to other users tasks' do
      other_task = create(:task, user: other_user)
      get task_path(other_task)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /tasks' do
    before { sign_in user }

    context 'with valid parameters' do
      let(:valid_params) do
        { task: { title: 'New Task', description: 'Task description', due_at: 1.day.from_now } }
      end

      it 'creates a new task' do
        expect {
          post tasks_path, params: valid_params
        }.to change { user.tasks.count }.by(1)
      end

      it 'redirects to the task' do
        post tasks_path, params: valid_params
        expect(response).to redirect_to(tasks_path)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        { task: { title: '', description: 'Task description' } }
      end

      it 'does not create a task' do
        expect {
          post tasks_path, params: invalid_params
        }.not_to change { Task.count }
      end

      it 'renders the new template' do
        post tasks_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PATCH /tasks/:id' do
    before { sign_in user }

    context 'with valid parameters' do
      let(:new_title) { 'Updated Title' }

      it 'updates the task' do
        patch task_path(task), params: { task: { title: new_title } }
        task.reload
        expect(task.title).to eq(new_title)
      end

      it 'redirects to the task' do
        patch task_path(task), params: { task: { title: new_title } }
        expect(response).to redirect_to(tasks_path)
      end
    end

    it 'prevents updating other users tasks' do
      other_task = create(:task, user: other_user)
      patch task_path(other_task), params: { task: { title: 'Hacked' } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /tasks/:id' do
    before { sign_in user }

    it 'deletes the task' do
      task_to_delete = create(:task, user: user)
      expect {
        delete task_path(task_to_delete)
      }.to change { user.tasks.count }.by(-1)
    end

    it 'redirects to tasks list' do
      delete task_path(task)
      expect(response).to redirect_to(tasks_path)
    end

    it 'prevents deleting other users tasks' do
      other_task = create(:task, user: other_user)
      delete task_path(other_task)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /tasks/:id/toggle_complete' do
    before { sign_in user }

    it 'marks incomplete task as complete' do
      patch toggle_complete_task_path(task)
      task.reload
      expect(task.completed_at).to be_present
    end

    it 'marks complete task as incomplete' do
      completed_task = create(:task, :completed, user: user)
      patch toggle_complete_task_path(completed_task)
      completed_task.reload
      expect(completed_task.completed_at).to be_nil
    end

    it 'redirects to tasks list' do
      patch toggle_complete_task_path(task)
      expect(response).to redirect_to(tasks_path)
    end
  end
end
