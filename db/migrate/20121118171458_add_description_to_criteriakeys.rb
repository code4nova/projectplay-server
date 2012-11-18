class AddDescriptionToCriteriakeys < ActiveRecord::Migration
  def change
    add_column :criteriakeys, :description, :string
  end
end
