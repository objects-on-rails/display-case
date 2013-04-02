module DisplayCase
  class Railtie < Rails::Railtie
    # http://guides.rubyonrails.org/configuring.html#initialization-events
    # "to_prepare will run upon every request in development, but only once (during boot-up) in production and test."
    config.to_prepare do
      DisplayCase.find_definitions if Rails.env.development?
    end
  end
end
