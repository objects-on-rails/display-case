module DisplayCase
  class Railtie < Rails::Railtie
    initializer "display_case.load_exhibits" do |app|
      ActiveSupport.on_load :display_case do
        DisplayCase.find_definitions
      end
    end
  end
end