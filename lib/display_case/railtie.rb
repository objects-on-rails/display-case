module DisplayCase
  class Railtie < Rails::Railtie
    config.to_prepare do
      DisplayCase.find_definitions if Rails.env.development?
    end    
  end
end