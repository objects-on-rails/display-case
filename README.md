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
  def self.applicable_to?(object, context)
    object.class.name == 'League'
  end

  def render_icon(template)
    # Use `object` local variable in partial to refer back to the exhibited
    # object
    render(template, partial: 'leagues/icon')

    # OR

    # Specify a local variable and "reexhibit" the model associated with `self`.
    # Using `exhibit(to_model)` ensures that `league`'s exhibit chain includes
    # all possible exhibit objects instead of just `self` (or LeagueExhibit,
    # in this example).
    render(template, partial: 'leagues/icon', locals: { league: exhibit(to_model) })
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

Note: See [#51](https://github.com/objects-on-rails/display-case/pull/51) for more on the need for `exhibit(to_model)` when rendering a partial from an exhibit.

Configuration
-------------
Several configuration options can be set via an initializer:

1. `definition_file_paths` Because Rails lazily-loads files, in development mode DisplayCase will search /app/exhibits to load the Exhibits found there. If your Exhibits are elsewhere, you can set `config.definition_file_paths = ['list/of/directories', 'to/find/exhibits']` in your initializers/display_case.rb.
1. `explicit` By default this option is false and Exhibits will be dynamically added via the inherited callback.
1. `exhibits` If `explicit` is true you must explicitly set the Exhibits you wish to use in the order you want them evaluated. You can set `config.exhibits = [AnExhibit,AnotherExhibit]` in your initializers/display_case.rb.
1. `cache_store` If you configure a cache store, you can use it by calling the `cache` method in your Exhibits (see below).
1. `logging_enabled` Setting this to `true` will provide debug information about exhibits to the Rails logger, but may adversely affect performance when many objects are being exhibited.
1. `smart_matching`  A boolean indicating whether Exhibits with names that are similar to context should be favored over other exhibits. By default, this is true.

An example `initializers/display_case.rb`
```
DisplayCase.configure do |config|
  config.definition_file_paths = ['app/exhibits','some/other/path']
  config.explicit = true
  config.exhibits = [MyFirstExhibit,MySecondExhibit]
  config.cache_store = Rails.configuration.action_controller.perform_caching ? Rails.cache : nil
  config.logging_enabled = false
end
```

Caching
-------
You can cache the results of an operation in your exhibits by configuring DisplayCase to use a cache store, and then using the `cache` method.
If you do this, you ought not use a real cache in development mode, since you'll likely want to see changes you're making to code, which of
course won't happen if you cache the results.

Use the cache like you would in a Rails controller:

```ruby
class LeagueExhibit < DisplayCase::Exhibit
  def self.applicable_to?(object, context)
    object.class.name == 'League'
  end

  def render(context)
    cache key, options={} do
      # something that takes a long while, which might make you want
      # to cache this call to render
      context.render(partial: 'leagues/icon', locals: {league: self})
    end
  end
end
```

See [How key-based cache expiration works](http://37signals.com/svn/posts/3113-how-key-based-cache-expiration-works) for examples on
how to choose good keys.

Wrong url with extra parameters using an exhibited model?
------------------
See this issue for the reason: https://github.com/objects-on-rails/display-case/issues/8


TypeError: superclass mismatch for class MyExhibit
------------------
This error is common in development mode in code bases which `ExhibitB` inherits from `ExhibitA`, which inherits from `DisplayCase::Exhibit`. 
DisplayCase is doing a lot of messing around with your exhibits to make them respond appropriately as if they were the object you're exhibiting,
and that is _normally_ the cause of this error if you're using inheritance among exhibits.

However, since it's possible you could actually be inadvertently having a superclass mismatch, the recommended way around this error is to avoid 
the situation.

In case you're having this error, and you're confident that is _not_ happening, we do provide a configuration option to catch this 
error and reload the class anyway. :warning: But be warned, if it is a legitimate superclass mismatch, you won't catch it with 
this option turned on! :warning:

To turn on this option, in your DisplayCase initializer:

```ruby
DisplayCase.configure do |config|
  config.swallow_superclass_mismatch_for_exhibits = true
end
```
