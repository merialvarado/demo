ActiveAdmin.register Category do
  config.comments = true

  form do |f|
    f.inputs do
      f.input :name
      f.input :parent_id, :as => :select, :collection => Category.all, :member_label => :name_for_selects
    end
    f.actions
  end
  
  index do
    selectable_column
    id_column
    column :name
    column "Parent", :parent_name
    column :created_at
    column :updated_at
    default_actions
  end
  
  show do |category|
    attributes_table do
      rows :id, :name, :parent_name, :children_names, :created_at, :updated_at
    end
    active_admin_comments
  end
end
