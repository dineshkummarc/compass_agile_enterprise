class SecuredModel < ActiveRecord::Base
  belongs_to :secured_record, :polymorphic => true
  has_and_belongs_to_many :roles

  class << self
    def find_models_by_klass_and_role(model_klass, role)
     role        = Role.iid(role) if role.is_a? String
     model_klass = model_klass.to_s unless model_klass.is_a? String

     SecuredModel.joins(['join roles_secured_models on roles_secured_models.secured_model_id = secured_models.id'])
                 .where('secured_record_type = ? and role_id = ?', model_klass, role.id).collect(&:secured_record)
    end
  end

end
