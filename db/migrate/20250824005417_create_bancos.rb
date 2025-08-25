class CreateBancos < ActiveRecord::Migration[8.0]
  def change
    create_table :bancos do |t|
      t.string :nombre, null: false
      t.string :direccion, null: false
      t.decimal :latitud, precision: 10, scale: 8, null: false
      t.decimal :longitud, precision: 11, scale: 8, null: false
      t.decimal :evaluacion, precision: 3, scale: 2, default: 0.0

      t.timestamps
    end

    add_index :bancos, [:latitud, :longitud]
    add_index :bancos, :nombre
  end
end
