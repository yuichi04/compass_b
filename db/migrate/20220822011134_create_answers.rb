class CreateAnswers < ActiveRecord::Migration[6.1]
  def change
    create_table :answers do |t|

      t.string :uid
      t.json :answer

      t.timestamps
    end
  end
end
