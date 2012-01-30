DB = Sequel.sqlite

DB.instance_eval do
  
  create_table :assets do
    primary_key :id
    
    String      :name
    String      :type
    Integer     :size
    
    FalseClass  :complete
  end
  
  create_table :chunks do
    foreign_key :asset_id, :assets, null: false, on_delete: :cascade
    
    Integer     :number
    Integer     :size

    primary_key [:asset_id, :number]
  end
end