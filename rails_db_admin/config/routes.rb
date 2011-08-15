RailsDbAdmin::Engine.routes.draw do
  match 'base(/:action(/:table(/:id)))' => "base"
  match 'queries(/:action(/:table(/:id)))' => "queries"
end
