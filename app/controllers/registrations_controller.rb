class RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    game_index_path
  end

  def after_update_path_for(resource)
    edit_user_registration_path(resource)
  end
end