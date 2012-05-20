display_case
============

An implementation of the Exhibit pattern, as described in Objects on Rails


Because Rails lazily-loads files, in development mode DisplayCase will search /app/exhibits to load the Exhibits found there. If your Exhibits are elsewhere, you can set `DisplayCase.definition_file_paths = ['list/of/directories', 'to/find/exhibits']` in your config/environments/development.rb.