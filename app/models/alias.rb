class Alias < ActiveRecord::Base
  attr_accessible :aliasname, :playground_id
  
  belongs_to :playground
end
