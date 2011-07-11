class ProductPackage < ProductInstance
  
  def components
    ProdInstanceReln.find(:all, :conditions => ['prod_instance_id_to = ?',self.id]).collect{|reln| reln.prod_instance_from}
  end
  
end