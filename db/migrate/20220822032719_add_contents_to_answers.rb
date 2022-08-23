class AddContentsToAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :answers, :consultation, :string
    add_column :answers, :conclusion, :string
    add_column :answers, :common, :string
    add_column :answers, :info, :json
  end
end
