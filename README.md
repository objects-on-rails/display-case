display_case
============

An implementation of the Exhibit pattern, as described in Objects on Rails

Description
-----------
If the Model is concerned with storing and manipulating business data, and the View is concerned with displaying it, you can think of the Exhibit as standing between them deciding which data to show, and in what order. It may also provide some extra presentation-specific information (such as the specific URLs for related resources) which the business model has no knowledge of by itself.

The Exhibit object is so named because it is like a museum display case for an artifact or a work of art. It does not obscure any of the features of the object being presented. Rather, it tries to showcase the object in the best light to a human audience, while also presenting meta-information about the object and cross-references to other objects in the museum's collection.

Technically, exhibit objects are a type of Decorator specialized for presenting models to an end user. 

For the purposes of clarity, here's a rundown of the essential characteristics of an Exhibit object.

An Exhibit object:

1. **Wraps a single model instance.**
1. **Is a true Decorator.** All unrecognized messages are passed through to the underlying object. This facilitates a gradual migration to the use of Exhibits to encapsulate presentation knowledge, since they can be layered onto models without any change to the existing views. It also enables multiple Exhibits to be layered onto an object, each handling different aspects of presentation.
1. **Brings together a model and a context.** Exhibits need a reference to a "context" object—either a controller or a view context—in order to be able to render templates as well as construct URLs for the object or related resources.
1. **Encapsulates decisions about how to render an object.** The tell-tale of an Exhibit is telling an object "render yourself", rather than explicitly rendering a template and passing the object in as an argument.
1. **May modify the behavior of an object.** For instance, an Exhibit might impose a scope on a `Blog#entries` association which only returns entries that are visible to the current user (as determined from the Exhibit's controller context). Or it might reformat the return value of a `#social_security_number` method to include dashes and have all but the last four digits obscured: `***-**-5678`.

Installation
------------
`gem 'display_case'` in your Gemfile if you're using Bundler, or `gem install display_case` from the command line.

Usage
-----
Your exhibits will look something like this:
``` ruby
# app/exhibits/league_exhibit.rb

class LeagueExhibit < DisplayCase::Exhibit
  def self.applicable_to?(object)
    object.class.name == 'League'
  end
  
  def render_icon(template)
    template.render(partial: 'leagues/icon', locals: {league: self})
  end
end
```

Then in your controller, where you're instantiating a League, wrap it in a call to the `exhibit` helper to get the Exhibited object, rather than the raw one.
``` ruby
# app/controllers/leagues_controller.rb
class LeaguesController < ApplicationController
  include DisplayCase::ExhibitsHelper
  # ...
  def index
    # display_case automatically wraps the individual objects contained in 
    # an Enumerable or ActiveRecord::Relation collections
    @leagues = exhibit(League.all) 
  end
  
  def show
    # of course it will also wrap your individual objects
    @league = exhibit(League.find(params[:id]))
  end
end
```

Finally, in your view, you can use your Exhibit:
```
<!-- app/views/leagues/index.html.erb -->
<% @leagues.each do |league| %> 
  <%= league.render_icon(self) %> <!-- self is this "template", the parameter to the method we defined in LeagueExhibit -->
<% end %>
```

Configuration
-------------
Several configuration options can be set via an initializer:

1. `definition_file_paths` Because Rails lazily-loads files, in development mode DisplayCase will search /app/exhibits to load the Exhibits found there. If your Exhibits are elsewhere, you can set `config.definition_file_paths = ['list/of/directories', 'to/find/exhibits']` in your initializers/display_case.rb.
1. `explicit` By default this option is false and Exhibits will be dynamically added via the inherited callback.
1. `exhibits` If `explicit` is true you must explicitly set the Exhibits you wish to use in the order you want them evaluated. You can set `config.exhibits = [AnExhibit,AnotherExhibit]` in your initializers/display_case.rb.

An example `initializers/display_case.rb`
```
DisplayCase.configure do |config|
  config.definition_file_paths = ['app/exhibits','some/other/path']
  config.explicit = true
  config.exhibits = [MyFirstExhibit,MySecondExhibit]
end
```
