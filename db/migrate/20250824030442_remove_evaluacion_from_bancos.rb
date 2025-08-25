class RemoveEvaluacionFromBancos < ActiveRecord::Migration[8.0]
  def change
    remove_column :bancos, :evaluacion, :decimal
  end
end
