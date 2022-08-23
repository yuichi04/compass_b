class AddCourseToAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :answers, :course, :string
  end
end
