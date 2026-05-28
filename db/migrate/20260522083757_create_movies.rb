class CreateMovies < ActiveRecord::Migration[8.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.string :director
      t.date :release_date
      t.decimal :rating, precision: 3, scale: 1
      t.string :status
      t.references :genre, null: false, foreign_key: true

      t.timestamps
    end
  end
end
