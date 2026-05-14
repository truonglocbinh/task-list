FactoryBot.define do
  factory :task do
    association :user
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph(sentence_count: 2) }
    due_at { Time.current + rand(1..10).days }
    completed_at { nil }

    trait :completed do
      completed_at { Time.current }
    end

    trait :overdue do
      due_at { 2.days.ago }
      completed_at { nil }
    end

    trait :due_today do
      due_at { Time.current.end_of_day - 1.hour }
      completed_at { nil }
    end

    trait :with_attachments do
      after(:create) do |task|
        task.attachments.attach(
          io: File.open(Rails.root.join('public', '404.html')),
          filename: 'test-file.html',
          content_type: 'text/html'
        )
      end
    end
  end
end
